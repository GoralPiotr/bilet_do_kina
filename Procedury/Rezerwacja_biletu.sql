USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[rezerwacja_biletu3]    Script Date: 13.03.2022 17:30:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* Za sprawą procedury, użytkownik rezerwuje uprzednio wybrane miejsca.
Procedura rezerwuje tylko te miejsca, które zostały zarezerwowane przez
sesję użytkownia. Użytkownik wybiera z trzech rodzajów biletów, od których zależy cena biletu.
Dodatkowo procedura "przyznaje" zniżkę jeśli bilet został zakupiony na seans w odpowiednich godzinach
*/
ALTER       proc [dbo].[rezerwacja_biletu3]
(
@email varchar(50),
@rodzaj_biletu1 varchar(10) = 'Normalny',
@rodzaj_biletu2 varchar(10) = 'Normalny',
@rodzaj_biletu3 varchar(10) = 'Normalny'
)
as
begin try
begin tran
		declare @id_sesji as int
		set @id_sesji = (select @@SPID)
		declare @procrezerwująca as dbo.rezerwująca 
		;
			insert into @procrezerwująca (id_repertuaru,id_miejsca,email)
			select 
				 tr.id_repertuaru
				,tr.id_miejsca
				,@email
			from tymczasowa_rezerwacja as tr
			where tr.id_sesji = @id_sesji
			;
			delete from tymczasowa_rezerwacja
			where id_sesji = @id_sesji
			;
			update @procrezerwująca
			set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
									    where nazwa_biletu = @rodzaj_biletu1)
			where id = 1
			;
			update @procrezerwująca
			set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
									    where nazwa_biletu = @rodzaj_biletu2)
			where id = 2
			;
			update @procrezerwująca
			set id_rodzaju_biletu  = (select id_rodzaju_biletu from rodzaje_biletów 
									     where nazwa_biletu = @rodzaj_biletu3)
			where id = 3
			;
			insert into rezerwacja(id_repertuaru, id_miejsca,email,id_rodzaju_biletu)
			select id_repertuaru, id_miejsca,email,id_rodzaju_biletu from @procrezerwująca
commit
			select
			case when godzina <= '15:30' 
			then ceiling(sum(rb.cena_biletu) - (sum(rb.cena_biletu)*cast(0.25 as smallmoney)))
			else ceiling(sum(rb.cena_biletu)) end as koszt
			from @procrezerwująca as p
			inner join repertuar as r
			on p.id_repertuaru = r.id_repertuaru
			inner join rodzaje_biletów as rb
			on rb.id_rodzaju_biletu = p.id_rodzaju_biletu
			group by godzina
end try
begin catch
rollback
print 'Coś poszło nie tak'
;throw
end catch