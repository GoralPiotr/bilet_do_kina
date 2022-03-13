USE [bilet_kinowy]
GO
/*
Przechowanie danych uzyskanych z zewnêtrznego pliku xml
*/
/****** Object:  UserDefinedTableType [dbo].[xmlowa]    Script Date: 13.03.2022 18:34:31 ******/
CREATE TYPE [dbo].[xmlowa] AS TABLE(
	[id_sali] [smallint] NULL,
	[Nazwa_filmu] [varchar](50) NULL,
	[dzieñ] [date] NULL,
	[godzina] [time](0) NULL
)
GO


