CREATE TABLE [ara].[Config] (
    [Nome]         VARCHAR (128) NOT NULL,
    [ValoreInt]    INT           NULL,
    [ValoreString] VARCHAR (256) NULL,
    [ValoreFloat]  FLOAT (53)    NULL,
    CONSTRAINT [PK_ara_Config] PRIMARY KEY CLUSTERED ([Nome] ASC) WITH (FILLFACTOR = 70)
);

