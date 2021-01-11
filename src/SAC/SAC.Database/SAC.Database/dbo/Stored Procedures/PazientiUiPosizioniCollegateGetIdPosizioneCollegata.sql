

-- =============================================
-- Author:          Ettore Garulli
-- Create date: 2018-02-22
-- Description: Ottiene il nuovo identificatore per la posizione collegata
--              Questa SP viene chiamata dalla SP PazientiUIPosizioniCOllegateInserisci
--              Crea un codice del tipo PCYY00001
--
-- Modify date:	2020-02-19 - KYRYLO
-- Description:	Modificato il prefisso della posizione collegata da "PC" a "NM"
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiPosizioniCollegateGetIdPosizioneCollegata]
(
       @IdPosizioneCollegata VARCHAR(16) OUTPUT
)
AS
BEGIN
       SET NOCOUNT ON;
       DECLARE @Anno VARCHAR(4)
       DECLARE @Contatore VARCHAR(8)
       DECLARE @AsciCode INT 
       
       SET @IdPosizioneCollegata = NULL
       --
       -- Prelevo l'anno corrente
       --
       SET @Anno = CAST(YEAR(GETDATE()) AS VARCHAR(4))
       
       BEGIN TRANSACTION
       BEGIN TRY
             --
             -- Calcolo nuovo contatore
             --
             SELECT TOP 1 @Contatore = Contatore
             FROM PazientiPosizioniCollegateContatori
             WHERE Anno = @Anno 
             ORDER BY Contatore DESC
             IF @Contatore IS NULL 
             BEGIN
                    SET @Contatore = '00000'
             END
             ELSE
             BEGIN
                    DECLARE @Counter AS INT 
                    SET @Counter = CAST(@Contatore AS INTEGER)
                    SET @Counter = @Counter + 1
                    IF @Counter > 99999 
                    BEGIN
                           SET @Counter = 0
                    END
                    SET @Contatore = RIGHT('00000' + CAST(@Counter AS VARCHAR(5)), 5)
             END
             --
             -- Lo scrivo nella tabella dei contatori
             --
             IF NOT @Contatore IS NULL
             BEGIN
                    INSERT INTO PazientiPosizioniCollegateContatori(Anno, Contatore)
                    VALUES (@Anno, @Contatore)
             END
             
             COMMIT TRANSACTION
             
             --
             -- Valorizzo @IdPosizioneCollegata
             --
             SET @IdPosizioneCollegata = 'NM' + SUBSTRING(@Anno,3,2) + @Contatore
             
       END TRY
       BEGIN CATCH
             IF @@TRANCOUNT > 0
             BEGIN
               ROLLBACK TRANSACTION;
             END

             DECLARE @ErrorLogId INT
             EXECUTE LogError @ErrorLogId OUTPUT;
             EXECUTE RaiseErrorByIdLog @ErrorLogId 
             RETURN @ErrorLogId
             
       END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiPosizioniCollegateGetIdPosizioneCollegata] TO [DataAccessUi]
    AS [dbo];

