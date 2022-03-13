USE [bilet_kinowy]
GO
/****** Object:  Table [dbo].[historia_rezerwacji]    Script Date: 13.03.2022 17:01:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[historia_rezerwacji](
	[id_repertuaru] [int] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[email] [varchar](30) NOT NULL,
	[id_rodzaju_biletu] [int] NOT NULL,
	[id_rezerwacji] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rezerwacji] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[historia_repertuaru]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[historia_repertuaru](
	[id_sali] [smallint] NULL,
	[id_filmu] [int] NULL,
	[id_data] [smallint] NULL,
	[godzina] [varchar](5) NULL,
	[id_repertuaru] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_repertuaru] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[liczba_widzów_historia]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	create   view [dbo].[liczba_widzów_historia] as
	select id_filmu,COUNT(t.id_repertuaru) as ilość_osób,godzina_spr from 
	(
	select id_filmu, godzina,hrez.id_repertuaru,
	case when godzina >=  '15:00' then 'po 15:00'
	else 'przed 15:00' 
	end as godzina_spr
	
	from dbo.historia_rezerwacji as hrez
	right join dbo.historia_repertuaru as hrep
	on hrez.id_repertuaru =hrep.id_repertuaru
	) as t
	group by id_filmu,godzina_spr
GO
/****** Object:  Table [dbo].[repertuar]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[repertuar](
	[id_repertuaru] [int] IDENTITY(1,1) NOT NULL,
	[id_sali] [smallint] NULL,
	[id_filmu] [int] NULL,
	[id_dnia] [smallint] NULL,
	[godzina] [time](0) NULL,
 CONSTRAINT [rez_pk] PRIMARY KEY CLUSTERED 
(
	[id_repertuaru] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rezerwacja]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rezerwacja](
	[id_rezerwacji] [int] IDENTITY(1,1) NOT NULL,
	[id_repertuaru] [int] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[email] [varchar](30) NOT NULL,
	[id_rodzaju_biletu] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rezerwacji] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[liczba_widzów]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




	create   view [dbo].[liczba_widzów] as
	select id_filmu,COUNT(t.id_repertuaru) as ilość_osób,godzina_spr from 
	(
	select id_filmu, godzina, rez.id_repertuaru,
	case when godzina >='15:00' then 'po 15:00'
	else 'przed 15:00' 
	end as godzina_spr
	from dbo.rezerwacja as rez
	full join dbo.repertuar as rep
	on rez.id_repertuaru = rep.id_repertuaru
	) as t
	group by id_filmu,godzina_spr
GO
/****** Object:  Table [dbo].[filmy]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[filmy](
	[id_filmu] [int] IDENTITY(1,1) NOT NULL,
	[Nazwa_filmu] [varchar](50) NULL,
 CONSTRAINT [pk_id_filmu] PRIMARY KEY CLUSTERED 
(
	[id_filmu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[kalendarz]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kalendarz](
	[id_dnia] [smallint] IDENTITY(1,1) NOT NULL,
	[dzień] [date] NULL,
 CONSTRAINT [pk_id_dzień] PRIMARY KEY CLUSTERED 
(
	[id_dnia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Wyświetlane_filmy]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view [dbo].[Wyświetlane_filmy] 
WITH SCHEMABINDING
   as
select 
	 f.Nazwa_filmu
	,r.godzina
	,k.dzień
from dbo.repertuar as r
inner join dbo.filmy as f
on f.id_filmu = r.id_filmu
inner join dbo.kalendarz as k
on k.id_dnia = r.id_dnia
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [wid_index]    Script Date: 13.03.2022 17:01:44 ******/
CREATE UNIQUE CLUSTERED INDEX [wid_index] ON [dbo].[Wyświetlane_filmy]
(
	[dzień] ASC,
	[Nazwa_filmu] ASC,
	[godzina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[liczby]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[liczby](
	[id_liczby] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id_liczby] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rodzaje_biletów]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rodzaje_biletów](
	[id_rodzaju_biletu] [smallint] IDENTITY(1,1) NOT NULL,
	[nazwa_biletu] [varchar](10) NOT NULL,
	[cena_biletu] [smallmoney] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rodzaju_biletu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sale_kinowe]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sale_kinowe](
	[id_sali] [smallint] IDENTITY(1,1) NOT NULL,
	[nazwa_sali] [char](7) NULL,
	[pojemność] [int] NULL,
 CONSTRAINT [clastr_id_sali] PRIMARY KEY CLUSTERED 
(
	[id_sali] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tymczasowa_rezerwacja]    Script Date: 13.03.2022 17:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tymczasowa_rezerwacja](
	[id_repertuaru] [int] NOT NULL,
	[id_miejsca] [smallint] NOT NULL,
	[id_sesji] [smallint] NOT NULL,
	[czas_wyboru] [datetime] NULL,
 CONSTRAINT [klucz_główny_tr] PRIMARY KEY CLUSTERED 
(
	[id_repertuaru] ASC,
	[id_miejsca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [in_film]    Script Date: 13.03.2022 17:01:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [in_film] ON [dbo].[filmy]
(
	[Nazwa_filmu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [in_dzień]    Script Date: 13.03.2022 17:01:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [in_dzień] ON [dbo].[kalendarz]
(
	[dzień] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [rep_id_rep_sal_dni_godz]    Script Date: 13.03.2022 17:01:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [rep_id_rep_sal_dni_godz] ON [dbo].[repertuar]
(
	[id_dnia] ASC,
	[godzina] ASC,
	[id_filmu] ASC
)
INCLUDE([id_sali]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [rep_id_sali_godz_id_dnia]    Script Date: 13.03.2022 17:01:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [rep_id_sali_godz_id_dnia] ON [dbo].[repertuar]
(
	[id_sali] ASC,
	[godzina] ASC,
	[id_dnia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER INDEX [rep_id_sali_godz_id_dnia] ON [dbo].[repertuar] DISABLE
GO
/****** Object:  Index [nc_id_miej_id_rep]    Script Date: 13.03.2022 17:01:44 ******/
CREATE NONCLUSTERED INDEX [nc_id_miej_id_rep] ON [dbo].[rezerwacja]
(
	[id_repertuaru] ASC,
	[id_miejsca] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tymczasowa_rezerwacja] ADD  DEFAULT (getdate()) FOR [czas_wyboru]
GO
ALTER TABLE [dbo].[repertuar]  WITH CHECK ADD  CONSTRAINT [klo_id_filmu] FOREIGN KEY([id_filmu])
REFERENCES [dbo].[filmy] ([id_filmu])
GO
ALTER TABLE [dbo].[repertuar] CHECK CONSTRAINT [klo_id_filmu]
GO
ALTER TABLE [dbo].[repertuar]  WITH CHECK ADD  CONSTRAINT [rep_id_data] FOREIGN KEY([id_dnia])
REFERENCES [dbo].[kalendarz] ([id_dnia])
GO
ALTER TABLE [dbo].[repertuar] CHECK CONSTRAINT [rep_id_data]
GO
ALTER TABLE [dbo].[repertuar]  WITH CHECK ADD  CONSTRAINT [rep_id_sali] FOREIGN KEY([id_sali])
REFERENCES [dbo].[sale_kinowe] ([id_sali])
GO
ALTER TABLE [dbo].[repertuar] CHECK CONSTRAINT [rep_id_sali]
GO
ALTER TABLE [dbo].[rezerwacja]  WITH CHECK ADD  CONSTRAINT [fk_id_repertuar] FOREIGN KEY([id_repertuaru])
REFERENCES [dbo].[repertuar] ([id_repertuaru])
GO
ALTER TABLE [dbo].[rezerwacja] CHECK CONSTRAINT [fk_id_repertuar]
GO
ALTER TABLE [dbo].[rezerwacja]  WITH CHECK ADD  CONSTRAINT [fk_rodz_biletu] FOREIGN KEY([id_rodzaju_biletu])
REFERENCES [dbo].[rodzaje_biletów] ([id_rodzaju_biletu])
GO
ALTER TABLE [dbo].[rezerwacja] CHECK CONSTRAINT [fk_rodz_biletu]
GO
ALTER TABLE [dbo].[tymczasowa_rezerwacja]  WITH CHECK ADD  CONSTRAINT [fk_id_rep] FOREIGN KEY([id_repertuaru])
REFERENCES [dbo].[repertuar] ([id_repertuaru])
GO
ALTER TABLE [dbo].[tymczasowa_rezerwacja] CHECK CONSTRAINT [fk_id_rep]
GO
