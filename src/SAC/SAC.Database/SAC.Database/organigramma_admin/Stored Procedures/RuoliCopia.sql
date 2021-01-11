
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-14
-- Description: Copia della configurazione di un Ruolo su un altro Ruolo
-- Modify date: 
-- =============================================
CREATE PROC [organigramma_admin].[RuoliCopia]
(
 @IdRuoloOrigine uniqueidentifier,
 @IdRuoloDestinazione uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;
		--
		-- Copio i SISTEMI (organigramma.RuoliSistemi) del ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliSistemi(IdRuolo,IdSistema)
		SELECT @IdRuoloDestinazione AS IdRuolo , IdSistema
		FROM organigramma.RuoliSistemi 
		WHERE IdRuolo = @IdRuoloOrigine 
		
		--
		-- Copio le UNITA OPERATIVE (organigramma.RuoliUnitaOperative) del ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliUnitaOperative(IdRuolo,IdUnitaOperativa)
		SELECT @IdRuoloDestinazione AS IdRuolo , IdUnitaOperativa
		FROM organigramma.RuoliUnitaOperative
		WHERE IdRuolo = @IdRuoloOrigine 
		
		--
		-- Copio gli UTENTI/GRUPPI (organigramma.RuoliOggettiActiveDirectory) associati al ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliOggettiActiveDirectory(IdRuolo,IdUtente)
		SELECT @IdRuoloDestinazione AS IdRuolo , IdUtente
		FROM organigramma.RuoliOggettiActiveDirectory
		WHERE IdRuolo = @IdRuoloOrigine 
		
		--
		-- Copio gli ATTRIBUTI (organigramma.RuoliAttributi) del ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliAttributi(IdRuolo, CodiceAttributo, Note)
		SELECT @IdRuoloDestinazione AS IdRuolo, CodiceAttributo, Note
		FROM organigramma.RuoliAttributi
		WHERE IdRuolo = @IdRuoloOrigine 

		--
		-- Copio gli ATTRIBUTI dei SISTEMI (organigramma.RuoliSistemiAttributi) del ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliSistemiAttributi(IdRuoloSistema,CodiceAttributo,Note)
		SELECT 
			RS_DEST.Id AS IdRuoloSistema
			, RSA_ORIG.CodiceAttributo
			, RSA_ORIG.Note
		FROM 
			organigramma.RuoliSistemi AS RS_ORIG
			INNER JOIN organigramma.RuoliSistemiAttributi AS RSA_ORIG
				on RS_ORIG.ID = RSA_ORIG.IdRuoloSistema
			INNER JOIN organigramma.RuoliSistemi AS RS_DEST
				on RS_DEST.IdSistema = RS_ORIG.IdSistema
		WHERE 
			RS_ORIG.IdRuolo = @IdRuoloOrigine 
			AND RS_DEST.IdRuolo = @IdRuoloDestinazione 

		--
		-- Copio gli ATTRIBUTI delle UNITA OPERATIVE (organigramma.RuoliUnitaOperativeAttributi) del ruolo di origine nel ruolo di destinazione (è sempre un nuovo ruolo)
		--
		INSERT INTO organigramma.RuoliUnitaOperativeAttributi(IdRuoliUnitaOperative, CodiceAttributo, Note)		
		SELECT 
			RUO_DEST.Id AS IdRuoliUnitaOperative
			, RUOA_ORIG.CodiceAttributo
			, RUOA_ORIG.Note
		FROM 
			organigramma.RuoliUnitaOperative AS RUO_ORIG
			INNER JOIN organigramma.RuoliUnitaOperativeAttributi AS RUOA_ORIG
				on RUO_ORIG.ID = RUOA_ORIG.IdRuoliUnitaOperative
			INNER JOIN organigramma.RuoliUnitaOperative AS RUO_DEST
				on RUO_DEST.IdUnitaOperativa = RUO_ORIG.IdUnitaOperativa

		WHERE 
			RUO_ORIG.IdRuolo = @IdRuoloOrigine 
			AND RUO_DEST.IdRuolo = @IdRuoloDestinazione 


    COMMIT TRANSACTION;

    RETURN 0

  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END

