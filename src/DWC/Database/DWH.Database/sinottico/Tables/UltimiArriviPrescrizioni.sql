CREATE TABLE [sinottico].[UltimiArriviPrescrizioni] (
    [TipoPrescrizione] VARCHAR (32) NOT NULL,
    [DataArrivo]       DATETIME     NOT NULL,
    CONSTRAINT [PK_UltimiArriviPrescrizioni_TipoPrescrizione] PRIMARY KEY CLUSTERED ([TipoPrescrizione] ASC)
);

