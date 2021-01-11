
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-05
-- Description:	Ritorna il paziente filtrato per IdSac
-- =============================================
CREATE FUNCTION [sac].[OttienePazientePerIdSac]
(
	@IdSac UNIQUEIDENTIFIER
)
RETURNS 
@Pazienti TABLE 
(
	[Id] [uniqueidentifier] NOT NULL,
	[Cognome] [varchar](64) NULL,
	[Nome] [varchar](64) NULL,
	[CodiceFiscale] [varchar](16) NULL,
	[DataNascita] [datetime] NULL,
	[Sesso] [varchar](1) NULL,
	[LuogoNascitaCodice] [varchar](6) NULL,
	[LuogoNascitaDescrizione] [varchar](128) NULL,
	[CodiceSanitario] [varchar](16) NULL,
	[DataDecesso] [datetime] NULL,
	[NazionalitaCodice] [varchar](3) NULL,
	[NazionalitaDescrizione] [varchar](128) NULL,
	[DomicilioComuneCodice] [varchar](6) NULL,
	[DomicilioComuneDescrizione] [varchar](128) NULL,
	[DomicilioCap] [varchar](8) NULL,
	[DomicilioLocalita] [varchar](128) NULL,
	[DomicilioIndirizzo] [varchar](256) NULL,
	[ResidenzaComuneCodice] [varchar](6) NULL,
	[ResidenzaComuneDescrizione] [varchar](128) NULL,
	[ResidenzaIndirizzo] [varchar](256) NULL,
	[ResidenzaCap] [varchar](8) NULL,
	[NomeAnagraficaErogante] [varchar](16) NOT NULL,
	[CodiceAnagraficaErogante] [varchar](64) NOT NULL,
	[ConsensoAziendaleCodice] [int] NULL,
	[ConsensoAziendaleDescrizione] [varchar](64) NULL,
	[ConsensoAziendaleData] [datetime] NULL,
	[ConsensoSoleCodice] [int] NULL,
	[ConsensoSoleDescrizione] [varchar](64) NULL,
	[ConsensoSoleData] [datetime] NULL,
	[FusioneId] [uniqueidentifier] NULL,
	[FusioneProvenienza] [varchar](16) NULL,
	[FusioneIdProvenienza] [varchar](64) NULL,
	[Disattivato] [tinyint] NOT NULL
)
AS
BEGIN
	INSERT @Pazienti
	SELECT Id, Cognome, Nome, CodiceFiscale, DataNascita, Sesso, LuogoNascitaCodice, LuogoNascitaDescrizione
		, CodiceSanitario, DataDecesso, NazionalitaCodice, NazionalitaNome
		, DomicilioComuneCodice, DomicilioComuneDescrizione, DomicilioCap, DomicilioLocalita, DomicilioIndirizzo
		, ResidenzaComuneCodice, ResidenzaComuneDescrizione, ResidenzaIndirizzo, ResidenzaCap
		, NomeAnagraficaErogante, CodiceAnagraficaErogante
		, ConsensoAziendaleCodice, ConsensoAziendaleDescrizione, ConsensoAziendaleData
		, ConsensoSoleCodice, ConsensoSoleDescrizione, ConsensoSoleData
		, FusioneId, FusioneProvenienza, FusioneIdProvenienza, Disattivato
	FROM sac.Pazienti
	WHERE Id = @IdSac

	RETURN 
END