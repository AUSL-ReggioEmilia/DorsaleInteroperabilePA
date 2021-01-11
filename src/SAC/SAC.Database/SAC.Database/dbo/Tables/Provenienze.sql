CREATE TABLE [dbo].[Provenienze] (
    [Provenienza]         VARCHAR (16)  NOT NULL,
    [Descrizione]         VARCHAR (128) NULL,
    [EmailResponsabile]   VARCHAR (128) NULL,
    [FusioneAutomatica]   BIT           CONSTRAINT [DF_Provenienze_FusioneAutomatica] DEFAULT ((1)) NOT NULL,
    [DisabilitaRicercaWS] BIT           CONSTRAINT [DF_Provenienze_DisabilitaRicercaWS] DEFAULT ((0)) NOT NULL,
    [SoloPropriWS]        BIT           CONSTRAINT [DF_Provenienze_SoloPropriWS] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Provenienze] PRIMARY KEY CLUSTERED ([Provenienza] ASC) WITH (FILLFACTOR = 70)
);





