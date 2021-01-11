
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetPesoPaziente]
(
	  @Cognome VARCHAR(64)
	, @Nome VARCHAR(64)
	, @DataNascita DATETIME
	, @Sesso VARCHAR(1) 
	, @ComuneNascitaCodice VARCHAR(6) 
	, @Tessera VARCHAR(16)
)
RETURNS INT
AS
BEGIN
	---------------------------------------------------
	DECLARE @PesoCognome int
	DECLARE @PesoNome int
	DECLARE @PesoDataNascita int
	DECLARE @PesoSesso int
	DECLARE @PesoComuneNascitaCodice int
	DECLARE @PesoTessera int
	SET @PesoCognome = 5
	SET @PesoNome = 5
	SET @PesoDataNascita = 4
	SET @PesoSesso = 2
	SET @PesoComuneNascitaCodice = 4
	SET @PesoTessera = 1
	---------------------------------------------------
	
	DECLARE @Peso INT	
	SET @Peso = 0

	IF ISNULL(@Cognome, '') <> ''
		SET @Peso = @Peso +  @PesoCognome
	IF ISNULL(@Nome, '') <> ''
		SET @Peso = @Peso +  @PesoNome
	IF ISNULL(CAST(@DataNascita as varchar(32)), '') <> ''
		SET @Peso = @Peso +  @PesoDataNascita
	IF ISNULL(@Sesso, '') <> ''
		SET @Peso = @Peso +  @PesoSesso
	IF ISNULL(@ComuneNascitaCodice, '') <> ''
		SET @Peso = @Peso +  @PesoComuneNascitaCodice
	IF ISNULL(@Tessera, '') <> ''
		SET @Peso = @Peso +  @PesoTessera
	--
	-- Restituisco il peso
	--
	RETURN @Peso

END

