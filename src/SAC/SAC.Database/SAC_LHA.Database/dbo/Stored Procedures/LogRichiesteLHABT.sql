
CREATE PROCEDURE [dbo].[LogRichiesteLHABT]
 @IdLHA varchar(20),
 @TipoOperazione varchar(1),
 @XmlPersona xml,
 @XmlEsenzioni xml,
 @XmlConsensi xml      
AS
BEGIN
 BEGIN TRY
  SET NOCOUNT ON
/****
 if not(@IdLHA is null)  
 BEGIN
  INSERT INTO [LogRichieste]
     ([IdLHA]
     ,[TipoOperazione]
     ,[XmlMessaggioPersona]
     ,[XmlMessaggioEsenzioni]
     ,[XmlMessaggioConsensi])
  VALUES
     (@IdLHA,
     @TipoOperazione,
     @XmlPersona,
     @XmlEsenzioni,
     @XmlConsensi)
  SELECT * FROM [LogRichieste] where id = @@Identity
  END
***/
 END TRY
 BEGIN CATCH
 
 END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LogRichiesteLHABT] TO [Execute Biztalk]
    AS [dbo];

