USE [bilet_kinowy]
GO
/*
Tabela wykorzystywana do tymczasowego przechowania danych dotyczących rezerwacji miejsca
*/
/****** Object:  UserDefinedTableType [dbo].[rezerwująca]    Script Date: 13.03.2022 18:32:33 ******/
CREATE TYPE [dbo].[rezerwująca] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_repertuaru] [smallint] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[email] [varchar](30) NOT NULL,
	[id_rodzaju_biletu] [smallint] NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO


