USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[dodaj_repertuar]    Script Date: 21.06.2022 13:14:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[dodaj_repertuar]
as
begin try
begin tran
begin
------ Zadeklarowanie zmiennych
declare @tymczasowa as dbo.xmlowa
declare			 @x	as xml
		select @x = bulkcolumn 
		  from openrowset(bulk 'D:\SQL\XML\repertuar2.xml',single_blob) as tabela; 
declare @idoc as int
	   EXEC sp_xml_preparedocument @idoc OUTPUT, @x
------ Przetworzenie danych 
	   insert into @tymczasowa
			SELECT * 
			  FROM OPENXML(@idoc, '/Seanse/film', 2)
			  WITH 
				  (
					id_sali smallint, 
					Nazwa_filmu varchar(50), 
					dzień date,
					godzina time(0)
				  )	
		EXEC sp_xml_removedocument  @idoc 
------ Dodanie nowego filmu do tabeli dbo.filmy
		merge dbo.filmy
		using 
				( 
					select max(nazwa_filmu) as nazwa_filmu 
					  from @tymczasowa 
				  group by nazwa_filmu
				) as a
		  on dbo.filmy.Nazwa_filmu = a.Nazwa_filmu
		WHEN MATCHED 
		 and (dbo.filmy.Nazwa_filmu <> a.nazwa_filmu) 
		then
  UPDATE SET dbo.filmy.Nazwa_filmu = a.nazwa_filmu
		WHEN NOT MATCHED 
		THEN
	  insert(Nazwa_filmu)
	  values(a.nazwa_filmu);
------ Do tabeli dbo.repertuar zostają wartości kluczy obcych
		merge dbo.repertuar
		using
			(
				select t.id_sali
						, f.id_filmu
						, k.id_dnia
						, godzina 
				  from @tymczasowa as t
			inner join filmy       as f
					on f.Nazwa_filmu = t.Nazwa_filmu
			inner join kalendarz   as k 
					on k.dzień = t.dzień
			) as tab
			on dbo.repertuar.id_filmu = tab.id_filmu
		    and dbo.repertuar.id_sali = tab.id_sali
		    and dbo.repertuar.id_dnia = tab.id_dnia
		    and dbo.repertuar.godzina = tab.godzina
	WHEN MATCHED 
			and 
				(
				dbo.repertuar.id_sali <> tab.id_sali 
				or dbo.repertuar.id_dnia <> tab.id_dnia 
		        or dbo.repertuar.godzina <> tab.godzina
		        )
		    then
	  update set
				dbo.repertuar.id_filmu = tab.id_filmu
			when not matched 
			then 
		  insert (id_sali,id_filmu,id_dnia,godzina)
		  values (tab.id_sali,tab.id_filmu,tab.id_dnia,tab.godzina);
------
commit
end
end try
		begin catch 
		   rollback 
			  print 'Sprawdź godziny'
------ przywrócenie właściwej kolejności klucza głównego
declare @idr as int = (select isnull(MAX(id_repertuaru),0) 
					     from repertuar)
dbcc checkident('dbo.repertuar',reseed,@idr)
declare @idf as int = (select isnull(MAX(id_filmu),0) 
						 from filmy)
dbcc checkident('dbo.filmy',reseed,@idf)
end catch 

