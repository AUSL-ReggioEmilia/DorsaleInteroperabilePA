
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-05-22 ETTORE
-- Modify date: 2015-07-24 ETTORE: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo
--							e restituisco sempre l'IdAttivo
-- Modify date: 2016-05-11 sandro - Usa nuova Func
--
-- Description:			Sostituisce la dbo.Ws2PazienteRiepilogoAttributiById
		--Restituisce gli attributi SAC del Paziente
		--Eventualmente questa SP potrà in futuro restituire altri dati che possono essere definiti come "attributi"

-- =============================================
CREATE PROCEDURE [ws2].[PazienteRiepilogoAttributiById]
(
	@IdPazienti  UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPazienti = dbo.GetPazienteAttivoByIdSac(@IdPazienti)

	SELECT	IdPazientiBase AS IdPaziente
			, Nome, Valore
	FROM	[OttienePazienteAttributiPerIdSac](@IdPazienti) Attributo
	WHERE	Nome NOT IN (
				'Tessera', 'Cognome', 'Nome'
				, 'DataNascita', 'Sesso','CodiceFiscale'
				, 'CodiceTerminazione', 'DescrizioneTerminazione'
				, 'DataInserimento', 'DataModifica'
				, 'Occultato', 'Disattivato'
				, 'FusioneId', 'FusioneProvenienza', 'FusioneIdProvenienza'
			)
END

