USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[dodaj_repertuar2]    Script Date: 13.03.2022 17:16:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
Za sprawą procedury dodajemy do bazy danych, z pliku zewnętrznego 
repertuar, który ma obowiązywać w danym czasie. 
W przypadku gdy w plku pojawi się nowy film, procedura doda go do odpowiedniej
tabeli
*/
ALTER     proc [dbo].[dodanie_repertuaru]
as
begin try
begin tran
begin
	declare @tymczasowa as dbo.xmlowa
	declare @x as xml
	select @x = bulkcolumn from openrowset(bulk 'D:\SQL\XML\repertuar2.xml',single_blob) as tabela; 
DECLARE @idoc int
	EXEC sp_xml_preparedocument @idoc OUTPUT, @x
-- Przetworzenie danych 
insert into @tymczasowa
SELECT * FROM OPENXML(@idoc, '/Seanse/film', 2)
WITH (
		id_sali smallint, 
		Nazwa_filmu varchar(50), 
		dzień date,
		godzina time(0)
	)	
EXEC sp_xml_removedocument  @idoc 
;
insert into dbo.filmy
select distinct Nazwa_filmu from @tymczasowa as t
where Nazwa_filmu not in 
			(select Nazwa_filmu from dbo.filmy as f)
;
insert into dbo.repertuar
select tab.id_sali,tab.id_filmu,tab.id_dnia,tab.godzina from 
(
select t.id_sali,f.id_filmu,k.id_dnia,godzina from @tymczasowa as t
inner join filmy as f
on f.Nazwa_filmu = t.Nazwa_filmu
inner join kalendarz as k 
on k.dzień = t.dzień
) as tab
where not exists (
					select * from dbo.repertuar as r
					where r.id_dnia = tab.id_dnia
					and r.id_sali = tab.id_sali
					and r.godzina = tab.godzina
				 )
commit
end
end try
begin catch
rollback
print 'Sprawdź godziny'
declare @idr as int = (select isnull(MAX(id_repertuaru),0) from repertuar)
dbcc checkident('dbo.repertuar',reseed,@idr)
declare @idf as int = (select isnull(MAX(id_filmu),0) from filmy)
dbcc checkident('dbo.filmy',reseed,@idf)
end catch

