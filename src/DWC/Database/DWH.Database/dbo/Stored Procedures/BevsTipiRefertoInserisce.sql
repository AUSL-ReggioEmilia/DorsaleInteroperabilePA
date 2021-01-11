-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-09-13
-- Description: Inserisce una riga di dbo.TipiReferto
-- Modify date: 2017-07-10 - SimoneB: Inserito parametro @AziendaErogante
-- =============================================
CREATE PROCEDURE [dbo].[BevsTipiRefertoInserisce]
(	
	@SistemaErogante varchar(16),
	@SpecialitaErogante varchar(64),
	@Descrizione varchar(128),
	@Icona varbinary(max),
	@Ordinamento int,
	@AziendaErogante VARCHAR(16)
)
AS
BEGIN
	DECLARE @NEWID UNIQUEIDENTIFIER = NEWID()
	
	INSERT INTO [dbo].[TipiReferto]
           ([Id]
           ,[SistemaErogante]
           ,[SpecialitaErogante]
           ,[Descrizione]
           ,[Icona]
           ,[Ordinamento]
		   ,[AziendaErogante])
     VALUES
           (@NEWID,
			@SistemaErogante ,
			@SpecialitaErogante ,
			@Descrizione ,
			@Icona ,
			@Ordinamento,
			@AziendaErogante)
   
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTipiRefertoInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

