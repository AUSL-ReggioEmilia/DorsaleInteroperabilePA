CREATE TABLE [dbo].[DatiAggiuntivi] (
    [Nome]              VARCHAR (128) NOT NULL,
    [DataInserimento]   DATETIME2 (0) CONSTRAINT [DF_DatiAggiuntivi_DataInserimento] DEFAULT (getutcdate()) NOT NULL,
    [DataModifica]      DATETIME2 (0) CONSTRAINT [DF_DatiAggiuntivi_DataModifica] DEFAULT (getutcdate()) NOT NULL,
    [UtenteInserimento] VARCHAR (64)  CONSTRAINT [DF_DatiAggiuntivi_UtenteInserimento] DEFAULT (suser_name()) NOT NULL,
    [UtenteModifica]    VARCHAR (64)  CONSTRAINT [DF_DatiAggiuntivi_UtenteModifica] DEFAULT (suser_name()) NOT NULL,
    [Descrizione]       VARCHAR (256) NULL,
    [Visibile]          BIT           CONSTRAINT [DF_DatiAggiuntivi_Visibile] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DatiAggiuntivi] PRIMARY KEY CLUSTERED ([Nome] ASC) WITH (FILLFACTOR = 95)
);

