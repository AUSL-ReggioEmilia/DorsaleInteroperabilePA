CREATE TABLE [dbo].[ConsensiConfig] (
    [Nome]         VARCHAR (128) NOT NULL,
    [ValoreInt]    INT           NULL,
    [ValoreString] VARCHAR (256) NULL,
    [ValoreFloat]  FLOAT (53)    NULL,
    CONSTRAINT [PK_ConsensiConfig] PRIMARY KEY CLUSTERED ([Nome] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiConfig_ConfigNome] FOREIGN KEY ([Nome]) REFERENCES [dbo].[ConfigNome] ([Nome])
);

