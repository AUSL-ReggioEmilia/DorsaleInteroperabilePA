CREATE TABLE [dbo].[PazientiConfig] (
    [Nome]         VARCHAR (128) NOT NULL,
    [ValoreInt]    INT           NULL,
    [ValoreString] VARCHAR (256) NULL,
    [ValoreFloat]  FLOAT (53)    NULL,
    CONSTRAINT [PK_PazientiConfig] PRIMARY KEY CLUSTERED ([Nome] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_PazientiConfig_ConfigNome] FOREIGN KEY ([Nome]) REFERENCES [dbo].[ConfigNome] ([Nome])
);

