-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-09-13
-- Description: Aggiorna una riga di dbo.TipiReferto
-- Modify date: 2017-07-10 - SimoneB: Inserito parametro @AziendaErogante
-- =============================================
CREATE PROCEDURE [dbo].[BevsTipiRefertoModifica]
(
	@Id UNIQUEIDENTIFIER, 
	@SistemaErogante varchar(16),
	@SpecialitaErogante varchar(64),
	@Descrizione varchar(128),
	@Icona varbinary(max),
	@Ordinamento int,
	@AziendaErogante VARCHAR(16)
)
AS
BEGIN

   UPDATE [dbo].[TipiReferto]
   SET [SistemaErogante] = @SistemaErogante
      ,[SpecialitaErogante] = @SpecialitaErogante
      ,[Descrizione] = @Descrizione
      ,[Icona] = @Icona
      ,[Ordinamento] = @Ordinamento
	  ,[AziendaErogante]  =@AziendaErogante
   OUTPUT 
       INSERTED.[Id]
      ,INSERTED.[SistemaErogante]
      ,INSERTED.[SpecialitaErogante]
      ,INSERTED.[Descrizione]
      ,INSERTED.[Icona]
      ,INSERTED.[Ordinamento]  
	  ,INSERTED.[AziendaErogante]     
    WHERE Id = @Id
   
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTipiRefertoModifica] TO [ExecuteFrontEnd]
    AS [dbo];

