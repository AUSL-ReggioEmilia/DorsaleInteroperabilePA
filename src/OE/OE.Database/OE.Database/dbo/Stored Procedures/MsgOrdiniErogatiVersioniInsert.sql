
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-20
-- Modify date: 2014-03-10 SANDRO: Compressione XML
-- Description:	Inserisce una nuova versione dell'ordine erogato
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiVersioniInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineErogatoTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	DECLARE @DatiVersione xml
	SET @DatiVersione = dbo.GetXMLOrdineErogato(@IDOrdineErogatoTestata)
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
	DECLARE @StatoComplessione tinyint = 0
		
	IF DATALENGTH(CONVERT(VARBINARY(MAX), @DatiVersione)) = @VerificaDataLen
		BEGIN
			-- Salvo non compresso
			SET @DatiVersione = CONVERT(xml, '<Root />')
			SET @StatoComplessione = 2
		END
	ELSE
		BEGIN
			-- Errore, salvo non compresso
			SET @DatiVersioneXmlCompresso = NULL
			SET @StatoComplessione = 3	
		END
	------------------------------
	-- INSERT
	------------------------------		
	INSERT INTO OrdiniErogatiVersioni
	(
		  ID
		, DataInserimento
		, IDTicketInserimento
		, IDOrdineErogatoTestata
		, StatoOrderEntry
		, DatiVersione
		, DatiVersioneXmlCompresso
		, StatoCompressione
	)
	VALUES
	(
		  @ID
		, @DataInserimento
		, @IDTicketInserimento
		, @IDOrdineErogatoTestata
		, @StatoOrderEntry
		, @DatiVersione
		, @DatiVersioneXmlCompresso
		, @StatoComplessione
	)
				
	SELECT @@ROWCOUNT AS [ROWCOUNT]
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiVersioniInsert] TO [DataAccessMsg]
    AS [dbo];

