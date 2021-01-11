
CREATE PROCEDURE [Progel].[CreaSP] 
(
	@TABLENAME VARCHAR(200),			-- Nome della tabella
	@PREFIX VARCHAR(200)	= '',		-- Prefisso da dare alle SP
	@SCHEMA VARCHAR(200)	= '',		-- Schema da dare alle SP
	@ROLE VARCHAR(200)		= ''		-- Utente/Ruolo a cui date il GRANT	
)
AS
BEGIN

	/******************************************************************************
		Descrizione    
	*******************************************************************************
		Questa StoredProcedure serve per creare le SP:
			- Inserisce
			- Modifica
			- Rimuove
			- Ottieni
			- Cerca
			- OttieniPer (Ne viene creata 1 per ogni FK della tabella)
		
		Parametri input:
			- Nome della tabella per cui costruire le SP
			- Prefisso da dare alle SP
			- Schema da dare alle SP (se dbo allora passare vuoto)
			- Ruolo / Utente a cui dare i Grant Execute sulle SP
		
		Output:
			Script di creazione delle SP
		
		Esempio d'uso:
			EXEC _CreaSP 'Interventi', '', 'Web', 'MythosWeb'
			
	      
	*******************************************************************************
		Versioni    
	*******************************************************************************
		Versione:		Data:			Autore:			Descrizione:
		1.0				20/06/2013		Andrea			Creazione SP
		1.1				01/07/2013		Andrea			Inserita gestione Timestamp	    
		1.2				05/07/2013		Andrea			Modifica gestione TOP nella cerca (non funzionava se passavi null da VB)
		1.3				18/07/2013		Sandro			Nome procedura cantralizzato e non tolgo da tabella lo schema
														Aggiunto EXECUTE dbo.RaiseErrorByIdLog
														Rinominato DettaglioPer in OttieniPer
														Tolti CR e TAB in più
														Modificata query per ricerca di PK (non riconosceva le IDENTITY)
														Modificata query per ricerca di FK
														Campi non in cerca 'TIMESTAMP', 'IMAGE', 'XML'
		1.4				31/10/2013		Andrea			Inserita gestione parametri PREFIX, SCHEMA, ROLE passati NULL
														Modificata lunghezza variabili @PARAMLIST, ... a VARCHAR(MAX)
														Inserita gestione '' passati come NULL nelle sp di inserimento e modifica
		1.5				29/05/2014		Sandro			Supporto alle VIEW (senza PK e FK)
														Per supportare i NewSequentialId il comando di INSERT usa l'opzione OUTPUT
															ed in più si lascia usare di default sulla colonna
		1.6				03/06/2014		Sandro			Migliorato il controllo sulla PK guid
														Usata sempre l'opzione OUTPUT insert, update e delete
														Gestione interna dei campi DataInserimento e DataModifica
														Gestione dei campi UtenteInserimento in SP insert
															 e UtenteModifica in SP update
															
   
	*******************************************************************************/
	
	DECLARE @DEBUG_TRACE BIT = 1

	-- Definizione e inizializzazione di alcuni parametri
	DECLARE @PARAMLIST VARCHAR(MAX) = ''		-- Elenco Parametri SP SENZA CHIAVE e TS
	DECLARE @PARAM_KEY VARCHAR(MAX) = ''			-- Parametro SP SOLO CHIAVE	
	DECLARE @PARAM_TS VARCHAR(MAX) = ''			-- Parametro SP SOLO TS	

	DECLARE @PARAM_USER_INSERT VARCHAR(MAX) = ''	-- Parametro SP UtenteInserimento	
	DECLARE @PARAM_USER_UPDATE VARCHAR(MAX) = ''	-- Parametro SP UtenteModifica
	
	DECLARE @COLUMNLIST VARCHAR(MAX) = ''		    -- Elenco Colonne SP ritornate select
	DECLARE @COLUMNLIST_OUT VARCHAR(MAX) = ''		-- Elenco Colonne SP ritornate output

	DECLARE @INSERTLIST VARCHAR(MAX) = ''			-- Elenco Colonne SP per insert SENZA CHIAVE
	DECLARE @INSERT_KEY VARCHAR(MAX) = ''			-- Colonne SP per insert CHIAVE

	DECLARE @VARLIST VARCHAR(MAX) = ''				-- Elenco Colonne con @ davanti per insert (SENZA CHIAVE)
	DECLARE @VAR_KEY VARCHAR(MAX) = ''				-- Colonne con @ davanti per insert (CHIAVE)
	
	DECLARE @UPDATELIST VARCHAR(MAX) = ''			-- Elenco Colonne = @Colonne per update
	
	DECLARE @PARAMLIST_CERCA VARCHAR(MAX) = ''	-- Elenco Parametri SP CERCA
	DECLARE @FILTERLIST_CERCA VARCHAR(MAX) = ''		-- Elenco Filtri SP CERCA

	DECLARE @CRLF CHAR(2) = CHAR(13) + CHAR(10)
	DECLARE @TAB CHAR(2) = '  '
	
	DECLARE @KEYNAME VARCHAR(50)
	DECLARE @KEYTYPE VARCHAR(50)
	DECLARE @IDENTITY BIT = 0
	DECLARE @ROWGUID BIT = 0
	DECLARE @NEWID BIT = 0
	DECLARE @TIMESTAMPNAME VARCHAR(50) = ''
	DECLARE @TIMESTAMP BIT = 0
	DECLARE @FKLIST VARCHAR(MAX) = ''
	DECLARE @TABLETYPE AS VARCHAR(1)

	DECLARE @USER_COL INT = 0
	DECLARE @DATA_COL INT = 0
	
	DECLARE @DATA_INSERT varchar(32) = 'DataInserimento'
	DECLARE @DATA_UPDATE varchar(32) = 'DataModifica'
	DECLARE @USER_INSERT varchar(32) = 'UtenteInserimento'
	DECLARE @USER_UPDATE varchar(32) = 'UtenteModifica'


	/***********************
	 Gestione errori parametri
	***********************/
	IF @PREFIX IS NULL 
	BEGIN
		SET @PREFIX = ''
	END
	
	IF @SCHEMA IS NULL 
	BEGIN
		SET @SCHEMA = ''
	END
	
	IF @ROLE IS NULL 
	BEGIN
		SET @ROLE = ''
	END
	
	DECLARE @PROCNAME VARCHAR(200) = ''

	
	DECLARE @GRANTSUSP int
	SET @GRANTSUSP = 0

	IF  ISNULL(@TABLENAME, '') = ''
	BEGIN
		PRINT 'Errore, passare il nome della tabella'
		GOTO FINE
	END
	ELSE
	BEGIN
		IF OBJECT_ID(@TABLENAME) IS NULL
		BEGIN
			PRINT 'Errore, tabella non trovata!'
			GOTO FINE
		END
		
		-- Compongo il patter per il nome delle SP
		SET @PROCNAME = REPLACE(REPLACE(REPLACE(@TABLENAME, ' ', '_'), ']', ''), '[', '')
		SET @PROCNAME = @PREFIX + SUBSTRING(@PROCNAME, CHARINDEX ('.',@PROCNAME) + 1, LEN(@PROCNAME) + 1) 

		-- Aggiungo le parentesi al nome
		SET @TABLENAME = '[' + REPLACE(@TABLENAME, '.', '].[') + ']'
		SET @TABLENAME = REPLACE(REPLACE(@TABLENAME, '[[', '['), ']]', ']')
	END 

	IF (ISNULL(@SCHEMA, '') = '')
	BEGIN
		-- se lo schema è vuoto allora devo mettere il grant sulle varie SP (e non sullo schema)
		SET @GRANTSUSP = 1
		-- se è vuoto anche il prefisso ritorno errore
		IF (ISNULL(@PREFIX, '') = '') 
		BEGIN
			PRINT 'Errore, occorre specificare almeno o il Prefisso o lo Schema'
			GOTO FINE
		END
		ELSE
		BEGIN
			-- per poter procedere serve comunque uno schema per cui lo setto a dbo
			SET @SCHEMA = 'dbo'
		END
	END

	-- se il ruolo è vuoto allora ne creo uno usando lo schema o il prefisso (almeno uno dei due c'è)
	IF (ISNULL(@ROLE, '') = '')
	BEGIN
		IF (ISNULL(@PREFIX, '') = '')
		BEGIN
			SET @ROLE = 'dataaccess_' + @SCHEMA
		END
		ELSE
		BEGIN
			SET @ROLE = 'dataaccess_' + @PREFIX
		END		
		PRINT 'CREATE ROLE ' + @ROLE
		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF	
	END

	-- Tipo di oggetto View o Table
	SELECT @TABLETYPE = xtype
		FROM sys.sysobjects
		WHERE id = OBJECT_ID(@TABLENAME)  

	--DEBUG
	IF @DEBUG_TRACE = 1
	BEGIN
		PRINT '-- @TABLENAME=' + ISNULL(@TABLENAME, '<NULL>')
		PRINT '-- @SCHEMA=' + ISNULL(@SCHEMA, '<NULL>')
		PRINT '-- @TABLETYPE=' + ISNULL(@TABLETYPE, '<NULL>')
		PRINT '-- @PREFIX=' + ISNULL(@PREFIX, '<NULL>')
		PRINT '-- @ROLE=' + ISNULL(@ROLE, '<NULL>')
	END
	
	/***********************
	 Recupero la chiave primaria (nome, tipo) e verifico se è un IDENTITY o ROWGUID
	***********************/
	
	SELECT TOP 1 @KEYNAME = sc.name
		,@KEYTYPE = st.Name
		,@ROWGUID = sc.is_rowguidcol
		,@IDENTITY = sc.is_identity
		,@NEWID = CASE WHEN sc.default_object_id = 0 THEN 0 ELSE 1 END
	FROM    sys.indexes AS i 
			INNER JOIN sys.index_columns AS ic
				ON  i.object_id = ic.object_id
					AND i.index_id = ic.index_id
					
			INNER JOIN sys.columns sc
				ON sc.object_id = ic.object_id
					AND sc.column_id = ic.column_id
					
			INNER JOIN sys.systypes st
				ON sc.system_type_id = st.xusertype 
	                                
	WHERE   i.is_primary_key = 1
		AND ic.OBJECT_ID = OBJECT_ID(@TABLENAME)

	/***********************
	 Controllo se nella tabella viene usato il timestamp
	***********************/
	SELECT @TIMESTAMP = 1, @TIMESTAMPNAME = sc.name
		FROM  syscolumns sc
			JOIN systypes st
				ON sc.xtype = st.xusertype     
	WHERE sc.id = OBJECT_ID(@TABLENAME)  
		  AND UPPER(st.name) = 'TIMESTAMP'

	/***********************
	 Recupero altre opzioni
	***********************/
	
	--Ci sono i campi UtenteInserimento e UtenteModifica
	SELECT @USER_COL = COUNT(*)
	FROM  syscolumns sc
	WHERE sc.id = OBJECT_ID(@TABLENAME) 
		AND (UPPER(sc.name) = UPPER(@USER_INSERT)
			OR UPPER(sc.name) = UPPER(@USER_UPDATE)
			)

	--Ci sono i campi DataInserimento e DataModifica
	SELECT @DATA_COL = COUNT(*)
	FROM  syscolumns sc
		JOIN  systypes st
			  ON sc.xtype = st.xusertype   
	WHERE sc.id = OBJECT_ID(@TABLENAME) 
		AND st.name LIKE '%datetime%' 
		AND (UPPER(sc.name) = UPPER(@DATA_INSERT)
			OR UPPER(sc.name) = UPPER(@DATA_UPDATE)
			)
		  
	--DEBUG
	IF @DEBUG_TRACE = 1
	BEGIN
		PRINT '-- @KEYNAME=' + ISNULL(@KEYNAME, '<NULL>')
		PRINT '-- @KEYTYPE=' + ISNULL(@KEYTYPE, '<NULL>')
		PRINT '-- @IDENTITY=' + CONVERT(VARCHAR(8), @IDENTITY)
		PRINT '-- @ROWGUID=' + CONVERT(VARCHAR(8), @ROWGUID)
		PRINT '-- @NEWID=' + CONVERT(VARCHAR(8), @NEWID)
		PRINT '-- @TIMESTAMP=' + CONVERT(VARCHAR(8), @TIMESTAMP)
		PRINT '-- @TIMESTAMPNAME=' + ISNULL(@TIMESTAMPNAME, '<NULL>')
		PRINT '-- @USER_COL=' + CONVERT(VARCHAR(8), @USER_COL)
		PRINT '-- @DATA_COL=' + CONVERT(VARCHAR(8), @DATA_COL)
		PRINT '-- @DATA_INSERT=' + CONVERT(VARCHAR(32), @DATA_INSERT)
		PRINT '-- @DATA_UPDATE=' + CONVERT(VARCHAR(32), @DATA_UPDATE)
		PRINT '-- @USER_INSERT=' + CONVERT(VARCHAR(32), @USER_INSERT)
		PRINT '-- @USER_UPDATE=' + CONVERT(VARCHAR(32), @USER_UPDATE)
	END
	
	/***********************
	 Salvo in una tabella temporanea tutte le FK
	***********************/
	SET NOCOUNT ON;

	DECLARE @FK TABLE (id int NOT NULL identity(1,1),
						name sysname,                    
						type  varchar(20),
						size  int)

	IF @TABLETYPE <> 'V'
	BEGIN
		INSERT INTO @FK
		SELECT 	
			fc.name,
			st.name,
			fc.length
		FROM sysobjects so
			INNER JOIN sysobjects so2 
				ON so.parent_obj = so2.id
			INNER JOIN sysreferences sr 
				ON so.id =  sr.constid
			INNER JOIN syscolumns fc 
				ON sr.fkeyid = fc.id and sr.fkey1 = fc.colid
			INNER JOIN systypes st ON fc.xtype = st.xusertype      
		WHERE so.type =  'F'
			AND fc.id = OBJECT_ID(@TABLENAME)  
	END
	ELSE
	BEGIN
		-- E' una vista cerco FK solo se chi chiamano uguali
		INSERT INTO @FK
		SELECT fc.name
			  ,st.name
			  ,fc.length
		FROM [INFORMATION_SCHEMA].[VIEW_COLUMN_USAGE] vc
		  
  				INNER JOIN syscolumns fc 
  					ON fc.id = OBJECT_ID(vc.[TABLE_SCHEMA] + '.' + vc.[TABLE_NAME]) 
  						AND fc.name = vc.[COLUMN_NAME]

				INNER JOIN sysreferences sr 
					ON sr.fkeyid = fc.id 
						AND sr.fkey1 = fc.colid

				INNER JOIN sysobjects so
					ON so.id =  sr.constid
						AND so.type =  'F'

				INNER JOIN sysobjects so2 
					ON so.parent_obj = so2.id
					
				INNER JOIN systypes st
					ON fc.xtype = st.xusertype      
		  
		WHERE VIEW_NAME = OBJECT_NAME(OBJECT_ID(@TABLENAME))
			AND VIEW_SCHEMA = OBJECT_SCHEMA_NAME(OBJECT_ID(@TABLENAME))
	END
	
	SELECT @FKLIST = @FKLIST + fk.name + @CRLF
		FROM @FK fk

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @FKLIST=' + @FKLIST + '*/'

	/***********************
	 Valorizzo @COLUMNLIST
	***********************/
	SELECT @COLUMNLIST = @COLUMNLIST + @TAB + @TAB + @TAB + '[' + sc.name + '],' + @CRLF
		FROM syscolumns sc
			JOIN systypes st
				ON sc.xtype = st.xusertype
		WHERE sc.id = OBJECT_ID(@TABLENAME)
		ORDER BY  sc.colorder

	-- Elimino l'ultimo carattere dalla variabile appena valorizzata (,)
	IF LEN(@COLUMNLIST) > 1
		SET @COLUMNLIST = LEFT(@COLUMNLIST,LEN(@COLUMNLIST)-3)

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @COLUMNLIST=' + @COLUMNLIST + '*/'
		
	/***********************
	 Valorizzo @PARAMLIST 
	***********************/
	SELECT @PARAMLIST = @PARAMLIST + ' @'+ sc.name +  ' '  + st.name  
			  +
					CASE st.name
						  WHEN 'char'           THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
						  WHEN 'varchar'        THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
						  WHEN 'binary'         THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
						  WHEN 'varbinary'		THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
						  ELSE ''
					END
			  + ',' + @CRLF
		FROM  syscolumns sc
			JOIN  systypes st
				  ON sc.xtype = st.xusertype   
		WHERE sc.id = OBJECT_ID(@TABLENAME)  
			AND UPPER(st.name) != 'TIMESTAMP'
			AND UPPER(sc.name) != UPPER(ISNULL(@KEYNAME,''))
			AND UPPER(sc.name) != UPPER(@DATA_INSERT)
			AND UPPER(sc.name) != UPPER(@DATA_UPDATE)
			AND UPPER(sc.name) != UPPER(@USER_INSERT)
			AND UPPER(sc.name) != UPPER(@USER_UPDATE)

		ORDER BY sc.colorder

	-- Elimino gli'ultimi carattere del loop e sistemo la lunghezza delle var (max)
	IF LEN(@PARAMLIST) > 1
	BEGIN
		SET @PARAMLIST = LEFT(@PARAMLIST, LEN(@PARAMLIST)-3)
		SET @PARAMLIST = REPLACE(@PARAMLIST, '(-1)', '(max)')
	END

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAMLIST=' + @PARAMLIST + '*/'


	/***********************
	 Valorizzo @PARAM_KEY
	***********************/
	SELECT @PARAM_KEY = ' @'+ sc.name + ' ' + st.name  
		      + CASE st.name
					  WHEN 'char'           THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'varchar'        THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'binary'         THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'nchar'          THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'nvarchar'       THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'varbinary'		THEN  '(' + CONVERT(varchar(10),sc.length) + ')'      
					  ELSE ''
				END
	FROM syscolumns sc
		JOIN systypes st
			  ON sc.xtype = st.xusertype
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		   AND UPPER(sc.name) = @KEYNAME
   
	-- La conversione di cui sopra trasforma gli eventuali varchar(max) in varchar(-1) risolvo facendo un replace
	IF LEN(@PARAM_KEY) > 1
		SET @PARAM_KEY = REPLACE(@PARAM_KEY, '(-1)', '(max)')
	
	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAM_KEY=' + @PARAM_KEY + '*/'
	
	/***********************
	 Valorizzo @PARAM_TS
	***********************/

	IF @TIMESTAMP = 1
	BEGIN
		SET @PARAM_TS = ' @' + @TIMESTAMPNAME + ' timestamp'
	END

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAM_TS=' + @PARAM_TS + '*/'
	

	/*****************************
	 Valorizzo @PARAM_USER_INSERT
	******************************/
	SELECT @PARAM_USER_INSERT = ' @'+ sc.name + ' ' + st.name  
		      + CASE st.name
					  WHEN 'char'           THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'varchar'        THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'binary'         THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'nchar'          THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'nvarchar'       THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'varbinary'		THEN  '(' + CONVERT(varchar(10),sc.length) + ')'      
					  ELSE ''
				END
	FROM syscolumns sc
		JOIN systypes st
			  ON sc.xtype = st.xusertype
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		   AND UPPER(sc.name) = @USER_INSERT
	
		--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAM_USER_INSERT=' + @PARAM_USER_INSERT + '*/'


	/*****************************
	 Valorizzo @PARAM_USER_INSERT
	******************************/
	SELECT @PARAM_USER_UPDATE = ' @'+ sc.name + ' ' + st.name  
		      + CASE st.name
					  WHEN 'char'           THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'varchar'        THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'binary'         THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'nchar'          THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'nvarchar'       THEN  '(' + CONVERT(varchar(10),sc.length/2) + ')'
					  WHEN 'varbinary'		THEN  '(' + CONVERT(varchar(10),sc.length) + ')'      
					  ELSE ''
				END
	FROM syscolumns sc
		JOIN systypes st
			  ON sc.xtype = st.xusertype
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		   AND UPPER(sc.name) = @USER_UPDATE

		--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAM_USER_UPDATE=' + @PARAM_USER_UPDATE + '*/'
	
	
	/***********************
	 Valorizzo @INSERTLIST
	***********************/
	SELECT @INSERTLIST = @INSERTLIST + @TAB + @TAB + @TAB + '[' + sc.name + '],' + @CRLF
		FROM syscolumns sc
			JOIN systypes st
			  ON sc.xtype = st.xusertype      
		WHERE sc.id = OBJECT_ID(@TABLENAME)		
				AND UPPER(st.name) <> 'TIMESTAMP'
				AND UPPER(sc.name) <> UPPER(ISNULL(@KEYNAME,''))
		ORDER BY sc.colorder

	-- Elimino l'ultimo carattere dalla variabile appena valorizzata (,)
	IF LEN(@INSERTLIST) > 1
		SET @INSERTLIST = LEFT(@INSERTLIST,LEN(@INSERTLIST)-3)	

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @INSERTLIST=' + @INSERTLIST + '*/'


	/***********************
	 Valorizzo @INSERT_KEY
	***********************/
	SELECT @INSERT_KEY = @TAB + @TAB + @TAB + '[' + sc.name + ']'
	FROM syscolumns sc
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		   AND UPPER(sc.name) = @KEYNAME
   
	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @INSERT_KEY=' + @INSERT_KEY + '*/'


	/***********************
	 Valorizzo @VARLIST
	***********************/
	SELECT @VARLIST = @VARLIST + @TAB + @TAB + @TAB +
			CASE st.name 
				WHEN 'VARCHAR' THEN 'NULLIF(@' + sc.name  + ', ''''),'
				ELSE '@'+ sc.name +  ','
			END + @CRLF
		FROM syscolumns sc
			JOIN systypes st
			  ON sc.xtype = st.xusertype
		WHERE sc.id = OBJECT_ID(@TABLENAME)
				AND UPPER(st.name) <> 'TIMESTAMP'
				AND UPPER(sc.name) <> UPPER(ISNULL(@KEYNAME,''))
		ORDER BY sc.colorder

	-- Elimino l'ultimo carattere dalla variabile appena valorizzata (,)
	IF LEN(@VARLIST) > 1
	BEGIN
		SET @VARLIST = LEFT(@VARLIST,LEN(@VARLIST)-3)
		SET @VARLIST = REPLACE(@VARLIST, '@' + @DATA_INSERT, 'GETDATE()')
		SET @VARLIST = REPLACE(@VARLIST, '@' + @DATA_UPDATE, 'GETDATE()')
		SET @VARLIST = REPLACE(@VARLIST, '@' + @USER_UPDATE, '@' + @USER_INSERT)
	END

	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @VARLIST=' + @VARLIST + '*/'


	/***********************
	 Valorizzo @VAR_KEY
	***********************/
	SELECT @VAR_KEY = @TAB + @TAB + @TAB + 
				CASE st.name 
					WHEN 'VARCHAR' THEN 'NULLIF(@' + sc.name  + ', '''')'
					ELSE '@'+ sc.name
				END
	FROM syscolumns sc
		JOIN systypes st
			  ON sc.xtype = st.xusertype
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		   AND UPPER(sc.name) = @KEYNAME
   
	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @VAR_KEY=' + @VAR_KEY + '*/'


	/***********************
	 Valorizzo @UPDATELIST
	***********************/ 
	SELECT  @UPDATELIST = @UPDATELIST + @TAB + @TAB + @TAB + '[' + sc.name + '] = ' +
			CASE st.name 
			WHEN 'VARCHAR' THEN 'NULLIF(@' + sc.name  + ', ''''),'
			ELSE '@' + sc.name  + ','
			END + @CRLF
	FROM syscolumns sc
		JOIN systypes st
			  ON sc.xtype = st.xusertype
	WHERE sc.id = OBJECT_ID(@TABLENAME)
		AND UPPER(st.name) != 'TIMESTAMP'
		AND UPPER(sc.name) != UPPER(ISNULL(@KEYNAME,''))
		AND UPPER(sc.name) != UPPER(@DATA_INSERT)
		AND UPPER(sc.name) != UPPER(@USER_INSERT)
	ORDER BY sc.colorder

	-- Elimino l'ultimo carattere dalla variabile appena valorizzata (,)
	IF LEN(@UPDATELIST) > 1
	BEGIN
		SET @UPDATELIST = LEFT(@UPDATELIST, LEN(@UPDATELIST)-3)
		SET @UPDATELIST = REPLACE(@UPDATELIST, '@' + @DATA_UPDATE, 'GETDATE()')
	END
	--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @UPDATELIST=' + @UPDATELIST + '*/'

	/***********************
	 Valorizzo @PARAMLIST_CERCA e @FILTERLIST_CERCA
	***********************/
	-- Al momento recupera i primi 10 campi della tabella escludendo PK, FK e TS	
	SELECT TOP 10 @PARAMLIST_CERCA = @PARAMLIST_CERCA + ' @'+ sc.name +  ' ' + st.name  
		  +
				CASE st.name
					  WHEN 'char'           THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'varchar'        THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'binary'         THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  WHEN 'varbinary'		THEN  '(' + CONVERT(varchar(10),sc.length) + ')'
					  ELSE ''
				END
		  + ' = NULL,' + @CRLF, 
		  @FILTERLIST_CERCA = @FILTERLIST_CERCA + @TAB + @TAB + @TAB +
				CASE st.name					  
					  WHEN 'varchar'        THEN  '(' + sc.name + ' LIKE @' + sc.name + ' + ''%'' OR ' + '@'+ sc.name + ' IS NULL)'					  
					  ELSE '(' + sc.name + ' = ' + '@'+ sc.name + ' OR ' + '@'+ sc.name + ' IS NULL)'
				END
			+ ' AND ' + @CRLF			
				
	FROM syscolumns sc
	JOIN systypes st
		  ON sc.xtype = st.xusertype   
	WHERE sc.id = OBJECT_ID(@TABLENAME) 
		  AND sc.length < 1024
		  AND UPPER(st.name) NOT IN ('TIMESTAMP', 'IMAGE', 'XML')
		  AND UPPER(sc.name) <> UPPER(ISNULL(@KEYNAME,''))
		  AND UPPER(sc.name) NOT IN (SELECT name FROM @FK)
	ORDER BY CASE sc.name WHEN @DATA_INSERT THEN 1
							WHEN @DATA_UPDATE THEN 2
							WHEN @USER_INSERT THEN 3
							WHEN @USER_UPDATE THEN 4
							ELSE 0 END,
			sc.colorder

	-- Elimino l'ultimo carattere del loop
	IF ISNULL(@PARAMLIST_CERCA, '') <> ''
	BEGIN
		SET @PARAMLIST_CERCA = LEFT(@PARAMLIST_CERCA,LEN(@PARAMLIST_CERCA)-3)
		SET @FILTERLIST_CERCA = LEFT(@FILTERLIST_CERCA,LEN(@FILTERLIST_CERCA)-7)
		SET @PARAMLIST_CERCA = REPLACE(@PARAMLIST_CERCA, '(-1)', '(max)')
	END
	
		--DEBUG
	IF @DEBUG_TRACE = 1
		PRINT '/* @PARAMLIST_CERCA=' + @PARAMLIST_CERCA + '*/'

	PRINT @CRLF
	PRINT '-----------------------------------------------------------------'
	PRINT @CRLF
	
	PRINT 'SET QUOTED_IDENTIFIER OFF'
	PRINT 'GO'
	PRINT 'SET ANSI_NULLS ON'
	PRINT 'GO'
	
	PRINT @CRLF
	PRINT '-----------------------------------------------------------------'
	PRINT @CRLF

	-- Se c'è la PK creo inserisce, modifica, cancella e ottieni
	IF LEN(@KEYNAME) > 1
	BEGIN
		SET @COLUMNLIST_OUT = REPLACE(@COLUMNLIST, '[', 'INSERTED.[')
	
		/***********************
		 Creazione SP Inserisce
		***********************/ 
		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'Inserisce]' 
		-- Nel caso in cui la chiave sia identity o un guid allora devo mettere i parametri senza chiave
		IF (@IDENTITY = 1) OR (@ROWGUID = 1) OR (@NEWID = 1)
		BEGIN
			PRINT '('
			
			IF @USER_COL > 0
				PRINT @PARAM_USER_INSERT + ','

			PRINT @PARAMLIST
			PRINT ')'
			PRINT 'AS'
			PRINT 'BEGIN'
			PRINT @TAB + 'SET NOCOUNT OFF'
			PRINT @CRLF
			PRINT @TAB + 'BEGIN TRY'
			PRINT @TAB + @TAB + 'BEGIN TRANSACTION;'
			PRINT @CRLF
			PRINT @TAB + @TAB + 'INSERT INTO ' + @TABLENAME 
			PRINT @TAB + @TAB + @TAB + '(' + @CRLF + @INSERTLIST
			PRINT @TAB + @TAB + @TAB + ')'
			PRINT @TAB + @TAB + ' OUTPUT ' + @CRLF + @COLUMNLIST_OUT
			PRINT @TAB + @TAB + ' VALUES'
			PRINT @TAB + @TAB + @TAB + '(' + @CRLF + @VARLIST
			PRINT @TAB + @TAB + @TAB + ')'
			PRINT @CRLF
			PRINT @TAB + @TAB + 'COMMIT TRANSACTION;'
		END
		ELSE
		BEGIN
			-- in tutti gli altri casi la chiave è un parametro gestito
			PRINT '('
			PRINT @PARAM_KEY + ','

			IF @USER_COL > 0
				PRINT @PARAM_USER_INSERT + ','

			PRINT @PARAMLIST
			PRINT ')'
			PRINT 'AS'
			PRINT 'BEGIN'
			PRINT @TAB + 'SET NOCOUNT OFF'
			PRINT @CRLF
			PRINT @TAB + 'BEGIN TRY'
			PRINT @TAB + @TAB + 'BEGIN TRANSACTION;'
			PRINT @CRLF
			PRINT @TAB + @TAB + 'INSERT INTO ' + @TABLENAME 
			PRINT @TAB + @TAB + @TAB + '('
			PRINT                       @INSERT_KEY + ','
			PRINT                       @INSERTLIST
			PRINT @TAB + @TAB + @TAB + ')'
			PRINT @TAB + @TAB + ' OUTPUT ' + @CRLF + @COLUMNLIST_OUT
			PRINT @TAB + @TAB + ' VALUES'
			PRINT @TAB + @TAB + @TAB + '('
			PRINT                       @VAR_KEY + ','
			PRINT                       @VARLIST
			PRINT @TAB + @TAB + @TAB + ')'
			PRINT @CRLF
			PRINT @TAB + @TAB + 'COMMIT TRANSACTION;'
		END

		PRINT @CRLF
		PRINT @TAB + @TAB + 'RETURN 0'

		PRINT @CRLF
		PRINT @TAB + 'END TRY'
		PRINT @TAB + 'BEGIN CATCH'
		PRINT @CRLF

		PRINT @TAB + @TAB + 'IF @@TRANCOUNT > 0'
		PRINT @TAB + @TAB + 'BEGIN'
		PRINT @TAB + @TAB + @TAB + 'ROLLBACK TRANSACTION;'
		PRINT @TAB + @TAB + 'END'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'DECLARE @ErrorLogId INT'
		PRINT @TAB + @TAB + 'EXECUTE dbo.LogError @ErrorLogId OUTPUT;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId'
		PRINT @TAB + @TAB + 'RETURN @ErrorLogId'
		PRINT @TAB + 'END CATCH;'
		PRINT 'END'
		PRINT 'GO'

		IF (@GRANTSUSP = 1)
		BEGIN
			PRINT 'GRANT EXEC ON '  + @SCHEMA + '.' + @PROCNAME + 'Inserisce TO ' + @ROLE
			PRINT 'GO'
		END	

		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF


		/***********************
		 Creazione SP Modifica
		***********************/ 	
		SET @COLUMNLIST_OUT = REPLACE(@COLUMNLIST, '[', 'INSERTED.[')

		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'Modifica]' 
		PRINT '('
	
		IF @TIMESTAMP = 1
		BEGIN
			PRINT @PARAM_KEY + ','
			PRINT @PARAM_TS + ','
		END
		ELSE
		BEGIN
			PRINT @PARAM_KEY + ','
		END

		IF @USER_COL > 0
			PRINT @PARAM_USER_UPDATE + ','
		
		PRINT @PARAMLIST
		
		PRINT ')'
		PRINT 'AS'
		PRINT 'BEGIN'
		PRINT @TAB + 'SET NOCOUNT OFF'
		PRINT @CRLF
		PRINT @TAB + 'BEGIN TRY'
		PRINT @TAB + @TAB + 'BEGIN TRANSACTION;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'UPDATE ' + @TABLENAME
		PRINT @TAB + @TAB + ' SET' + @CRLF + @UPDATELIST
		PRINT @TAB + @TAB + ' OUTPUT ' + @CRLF + @COLUMNLIST_OUT
		PRINT @TAB + @TAB + 'WHERE [' + @KEYNAME + '] = @'+ @KEYNAME
		
		IF @TIMESTAMP = 1
		BEGIN
			PRINT @TAB + @TAB + @TAB + 'AND [' + @TIMESTAMPNAME + '] = @'+ @TIMESTAMPNAME
		END
		
		PRINT @CRLF
		PRINT @TAB + @TAB + 'COMMIT TRANSACTION;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'RETURN 0'

		PRINT @CRLF
		PRINT @TAB + 'END TRY'
		PRINT @TAB + 'BEGIN CATCH'
		PRINT @CRLF

		PRINT @TAB + @TAB + 'IF @@TRANCOUNT > 0'
		PRINT @TAB + @TAB + 'BEGIN'
		PRINT @TAB + @TAB + @TAB + 'ROLLBACK TRANSACTION;'
		PRINT @TAB + @TAB + 'END'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'DECLARE @ErrorLogId INT'
		PRINT @TAB + @TAB + 'EXECUTE dbo.LogError @ErrorLogId OUTPUT;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId'
		PRINT @TAB + @TAB + 'RETURN @ErrorLogId'
		PRINT @TAB + 'END CATCH;'
		PRINT 'END'
		PRINT 'GO'
		
		IF (@GRANTSUSP = 1)
		BEGIN
			PRINT 'GRANT EXEC ON  ' + @SCHEMA + '.' + @PROCNAME + 'Modifica TO ' + @ROLE
			PRINT 'GO'
		END	
		
		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF


		/***********************
		 Creazione SP Rimuove
		***********************/ 
		SET @COLUMNLIST_OUT = REPLACE(@COLUMNLIST, '[', 'DELETED.[')

		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'Rimuove]' 
		PRINT '('
		
		IF @TIMESTAMP = 1
		BEGIN
			PRINT @PARAM_KEY + ','
			PRINT @PARAM_TS
		END
		ELSE
		BEGIN
			PRINT @PARAM_KEY
		END
		
		PRINT ')'
		PRINT 'AS'
		PRINT 'BEGIN'
		PRINT @TAB + 'SET NOCOUNT OFF'
		PRINT @CRLF
		PRINT @TAB + 'BEGIN TRY'
		PRINT @TAB + @TAB + 'BEGIN TRANSACTION;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'DELETE FROM ' + @TABLENAME
		PRINT @TAB + @TAB + ' OUTPUT ' + @CRLF + @COLUMNLIST_OUT
		PRINT @TAB + @TAB + 'WHERE [' + @KEYNAME + '] = @' + @KEYNAME
		IF @TIMESTAMP = 1
		BEGIN
			PRINT @TAB + @TAB + @TAB + 'AND [' + @TIMESTAMPNAME + '] = @'+ @TIMESTAMPNAME
		END
		PRINT @CRLF
		PRINT @TAB + @TAB + 'COMMIT TRANSACTION;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'RETURN 0'

		PRINT @CRLF
		PRINT @TAB + 'END TRY'
		PRINT @TAB + 'BEGIN CATCH'
		PRINT @CRLF

		PRINT @TAB + @TAB + 'IF @@TRANCOUNT > 0'
		PRINT @TAB + @TAB + 'BEGIN'
		PRINT @TAB + @TAB + @TAB + 'ROLLBACK TRANSACTION;'
		PRINT @TAB + @TAB + 'END'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'DECLARE @ErrorLogId INT'
		PRINT @TAB + @TAB + 'EXECUTE dbo.LogError @ErrorLogId OUTPUT;'
		PRINT @CRLF
		PRINT @TAB + @TAB + 'EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId'
		PRINT @TAB + @TAB + 'RETURN @ErrorLogId'
		PRINT @TAB + 'END CATCH;'
		PRINT 'END'
		PRINT 'GO'

		IF (@GRANTSUSP = 1)
		BEGIN
			PRINT 'GRANT EXEC ON  ' + @SCHEMA + '.' + @PROCNAME + 'Rimuove TO ' + @ROLE
			PRINT 'GO'
		END	

		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF


		/***********************
		 Creazione SP Ottieni
		***********************/ 
		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'Ottieni]' 
		PRINT '('
		PRINT @PARAM_KEY
		PRINT ')'
		PRINT 'AS'
		PRINT 'BEGIN'
		PRINT @TAB + 'SET NOCOUNT OFF'
		PRINT @CRLF
		PRINT @TAB + 'SELECT ' + @CRLF + @COLUMNLIST
		PRINT @TAB + 'FROM  ' + @TABLENAME
		PRINT @TAB + 'WHERE [' + @KEYNAME + '] = @' + @KEYNAME 
		PRINT @CRLF
		PRINT 'END'
		PRINT 'GO'
		
		IF (@GRANTSUSP = 1)
		BEGIN
			PRINT 'GRANT EXEC ON  ' + @SCHEMA + '.' + @PROCNAME + 'Ottieni TO ' + @ROLE
			PRINT 'GO'
		END	
		
		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF
		
	END	--LEN(@KEYNAME) > 1


	/***********************
	 Creazione SP Cerca
	***********************/ 	
	IF ISNULL(@PARAMLIST_CERCA, '') <> ''
	BEGIN
		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'Cerca]' 
		PRINT '('
		PRINT @PARAMLIST_CERCA + ','
		PRINT ' @Top INT = NULL'		
		PRINT ')'
		PRINT 'WITH RECOMPILE'
		PRINT 'AS'
		PRINT 'BEGIN'
		PRINT @TAB + 'SET NOCOUNT OFF'
		PRINT @CRLF
		PRINT @TAB + 'SELECT TOP (ISNULL(@Top, 100)) ' + @CRLF + @COLUMNLIST
		PRINT @TAB + 'FROM  ' + @TABLENAME
		PRINT @TAB + 'WHERE ' + @CRLF + @FILTERLIST_CERCA		
		PRINT @CRLF
		PRINT 'END'
		PRINT 'GO'

		IF (@GRANTSUSP = 1)
		BEGIN
			PRINT 'GRANT EXEC ON  ' + @SCHEMA + '.' + @PROCNAME + 'Cerca TO ' + @ROLE
			PRINT 'GO'
		END

		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF
	END

	/***********************
	 Per tutte le FK presenti nella tabella creo una Sp ByFK dedicata
	***********************/ 	
	-- ciclo per creare le varie SP
	DECLARE @pointer int
	DECLARE @FKNAME sysname
	DECLARE @FKSIZE int
	DECLARE @FKTYPE varchar(100)
	
	WHILE EXISTS (SELECT '*' FROM @fk)
	BEGIN
		SELECT @pointer = MAX(id) FROM @fk
		
		SELECT @FKNAME = name, @FKSIZE = size, @FKTYPE = TYPE 
		FROM @fk 
		WHERE id = @pointer
	    
		PRINT @CRLF
		PRINT @CRLF
		PRINT 'CREATE PROC [' + @SCHEMA + '].[' + @PROCNAME + 'OttieniPer' + @FKNAME + ']'
		PRINT '('
		PRINT ' @' + @FKNAME + ' ' + @FKTYPE + 
				CASE @FKTYPE 
					WHEN 'char'             THEN	'(' + CONVERT(varchar(10),@FKSIZE) + ')'
					WHEN 'varchar'          THEN	'(' + CONVERT(varchar(10),@FKSIZE) + ')'
					WHEN 'binary'           THEN	'(' + CONVERT(varchar(10),@FKSIZE) + ')'
					WHEN 'nchar'			THEN	'(' + CONVERT(varchar(10),@FKSIZE/2) + ')'
					WHEN 'nvarchar'			THEN	'(' + CONVERT(varchar(10),@FKSIZE/2) + ')'
					WHEN 'varbinary'		THEN	'(' + CONVERT(varchar(10),@FKSIZE) + ')'
					ELSE ''
				END
		PRINT ')'    
		PRINT 'AS'
		PRINT 'BEGIN'
		PRINT @TAB + 'SET NOCOUNT OFF'
		PRINT @CRLF
		PRINT @TAB + 'SELECT ' + @CRLF + @COLUMNLIST
		PRINT @TAB + 'FROM  ' + @TABLENAME
		PRINT @TAB + 'WHERE [' + @FKNAME + '] = @' + @FKNAME   
		PRINT @CRLF
		PRINT 'END'
		PRINT 'GO'  

		IF (@GRANTSUSP = 1)
		BEGIN  
			PRINT 'GRANT EXEC ON  ' + @SCHEMA + '.' + @PROCNAME + 'OttieniPer' + @FKNAME  + ' TO ' + @ROLE
			PRINT 'GO'	 
		END
	    	    
		DELETE FROM @fk WHERE id = @pointer
   
		PRINT @CRLF
		PRINT '-----------------------------------------------------------------'
		PRINT @CRLF
	END

	/***********************
	 Se lo schema è stato passato allora devo scrivere il grant
	***********************/ 
	IF (@GRANTSUSP = 0)
	BEGIN  
		PRINT 'GRANT EXECUTE ON SCHEMA:: ' + @SCHEMA + ' TO ' + @ROLE
	END

	FINE:

END

