
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-10
-- Modify date: 2014-03-10 SANDRO: Compressione XML
-- Description:	Inserisce una nuova versione dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniVersioniInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)
	, @Data datetime
	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	DECLARE @DatiVersione xml
	SET @DatiVersione = dbo.GetXMLOrdine(@IDOrdineTestata)
	--
	-- Comprimo XML
	--
	DECLARE @DatiVersioneXmlCompresso varbinary(max)
	SET @DatiVersioneXmlCompresso = dbo.compress(CONVERT(VARBINARY(MAX), @DatiVersione))
	--
	-- Decomprimo e verifico la lunghezza
	--
	DECLARE @VerificaDataLen int
	SET @VerificaDataLen = DATALENGTH(dbo.decompress(@DatiVersioneXmlCompresso))
	--
	-- Verifico la lunghezza
	--
	DECLARE @StatoCompressione tinyint = 0
		
	IF DATALENGTH(CONVERT(VARBINARY(MAX), @DatiVersione)) = @VerificaDataLen
		BEGIN
			-- Salvo non compresso
			SET @DatiVersione = CONVERT(xml, '<Root />')
			SET @StatoCompressione = 2
		END
	ELSE
		BEGIN
			-- Errore, salvo non compresso
			SET @DatiVersioneXmlCompresso = NULL
			SET @StatoCompressione = 3	
		END

	------------------------------
	-- INSERT
	------------------------------		
	INSERT INTO OrdiniVersioni
	(
		  ID
		, DataInserimento
		, IDTicketInserimento
		, IDOrdineTestata
		, Tipo
		, StatoOrderEntry
		, DatiVersione
		, Data
		, DatiVersioneXmlCompresso
		, StatoCompressione
	)
	VALUES
	(
		  @ID
		, @DataInserimento
		, @IDTicketInserimento
		, @IDOrdineTestata
		, 0
		, @StatoOrderEntry
		, @DatiVersione
		, @Data
		, @DatiVersioneXmlCompresso
		, @StatoCompressione
	)
				
	SELECT @@ROWCOUNT AS [ROWCOUNT]
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniVersioniInsert] TO [DataAccessMsg]
    AS [dbo];

