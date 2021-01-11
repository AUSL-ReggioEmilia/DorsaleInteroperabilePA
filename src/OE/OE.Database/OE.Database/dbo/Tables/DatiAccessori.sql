CREATE TABLE [dbo].[DatiAccessori] (
    [Codice]               VARCHAR (64)   NOT NULL,
    [DataInserimento]      DATETIME2 (0)  CONSTRAINT [DF_DatiAccessori_DataInserimento] DEFAULT (getdate()) NOT NULL,
    [DataModifica]         DATETIME2 (0)  CONSTRAINT [DF_DatiAccessori_DataModifica] DEFAULT (getdate()) NOT NULL,
    [Descrizione]          VARCHAR (256)  NULL,
    [Etichetta]            VARCHAR (64)   NOT NULL,
    [Tipo]                 VARCHAR (32)   NOT NULL,
    [Obbligatorio]         BIT            CONSTRAINT [DF_DatiAccessori_Obbligatorio] DEFAULT ((0)) NOT NULL,
    [Ripetibile]           BIT            CONSTRAINT [DF_DatiAccessori_Ripetibile] DEFAULT ((0)) NOT NULL,
    [Valori]               VARCHAR (MAX)  NULL,
    [Ordinamento]          INT            NULL,
    [Gruppo]               VARCHAR (64)   NULL,
    [ValidazioneRegex]     VARCHAR (MAX)  NULL,
    [ValidazioneMessaggio] VARCHAR (MAX)  NULL,
    [Sistema]              BIT            CONSTRAINT [DF_DatiAccessori_Sistema] DEFAULT ((0)) NOT NULL,
    [ValoreDefault]        VARCHAR (1024) NULL,
    [NomeDatoAggiuntivo]   VARCHAR (64)   NULL,
    [UtenteInserimento]    VARCHAR (64)   CONSTRAINT [DF_DatiAccessori_UtenteInserimento] DEFAULT (suser_name()) NOT NULL,
    [UtenteModifica]       VARCHAR (64)   CONSTRAINT [DF_DatiAccessori_UtenteModifica] DEFAULT (suser_name()) NOT NULL,
    [ConcatenaNomeUguale]  BIT            CONSTRAINT [DF_DatiAccessori_Concatena] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DatiAccessori] PRIMARY KEY CLUSTERED ([Codice] ASC) WITH (FILLFACTOR = 95)
);



