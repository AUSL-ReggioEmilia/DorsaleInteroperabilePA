CREATE TABLE [dbo].[OscuramentoRuoli] (
    [IdOscuramento]     UNIQUEIDENTIFIER NOT NULL,
    [IdRuolo]           UNIQUEIDENTIFIER NOT NULL,
    [DataInserimento]   DATETIME         CONSTRAINT [DF_OscuramentoRuoli_DataInserimento] DEFAULT (sysutcdatetime()) NOT NULL,
    [UtenteInserimento] VARCHAR (128)    CONSTRAINT [DF_OscuramentoRuoli_UtenteInserimento] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_OscuramentoRuoli] PRIMARY KEY CLUSTERED ([IdOscuramento] ASC, [IdRuolo] ASC),
    CONSTRAINT [FK_OscuramentoRuoli_Oscuramenti] FOREIGN KEY ([IdOscuramento]) REFERENCES [dbo].[Oscuramenti] ([Id])
);

