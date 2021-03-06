USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[kasowanie]    Script Date: 21.06.2022 13:29:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 Za sprawą procedury usuwamy dane o repertuarze 
 oraz rezerwacjach seansów które już się odbyły. Dane zostają przeniesione
 do dwóch innych tabel w celu wykonywania na nich kolejnych zadań
*/
ALTER   proc [dbo].[kasowanie]
as
begin
declare @data as date = getdate()
declare @id_dzień as int
set @id_dzień = 
				(select id_dnia 
				   from dbo.kalendarz 
				  where dzień = @data)
-----Usunięcie danych z tabeli dbo.rezerwacja i dodanie ich do dbo.historia_rezerwacji
	insert into dbo.historia_rezerwacji (id_repertuaru,id_miejsca,email,id_rodzaju_biletu,id_rezerwacji)
		 select id_repertuaru
		      , id_miejsca
			  , email
			  , id_rodzaju_biletu
			  , id_rezerwacji
	       from (delete from dbo.rezerwacja
                 output
						deleted.id_repertuaru,
						deleted.id_miejsca,
						deleted.email,
						deleted.id_rodzaju_biletu,
						deleted.id_rezerwacji
				  where id_repertuaru in 
						  (
							select id_repertuaru 
							  from repertuar 
							 where id_dnia < @id_dzień)
						  ) as tab
-----Usunięcie danych z tabeli dbo.repertuar i dodanie ich do tabeli dbo.historia_repertuaru
	insert into historia_repertuaru(id_sali,id_filmu,id_data,godzina,id_repertuaru)
		 select id_sali
		      , id_filmu
			  , id_dnia
			  , godzina
			  , id_repertuaru 
		   from (delete from dbo.repertuar
				 output
						deleted.id_sali,
						deleted.id_filmu,
						deleted.id_dnia,
						deleted.godzina,
						deleted.id_repertuaru
				  where id_dnia < @id_dzień) as tab
				end