USE [bilet_kinowy]
GO
/****** Object:  UserDefinedFunction [dbo].[suma_zarobków]    Script Date: 21.06.2022 19:55:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Funkcja oblicza jaki został osięgnięty wpływ z biletów dla danego filmu
*/
ALTER       function [dbo].[suma_zarobków] (@id_filmu as int)
returns money
as
begin
declare @suma as money
	set @suma = 
	(
	select cast(SUM(zarobek) as decimal (5,2)) as zarobek 
	  from 
	  (
		  select rep.id_filmu
		       , case when rep.godzina < '15:30:00' 
		         then ceiling(SUM(rb.cena_biletu) - SUM(rb.cena_biletu)*0.25)
		         else SUM(rb.cena_biletu) 
			 end as Zarobek
		    from rodzaje_biletów     as rb
      	      inner join historia_rezerwacji as r
		      on r.id_rodzaju_biletu = rb.id_rodzaju_biletu
              inner join historia_repertuaru as rep
		      on rep.id_repertuaru   = r.id_repertuaru
		   where rep.id_filmu = @id_filmu
	        group by id_filmu,rep.godzina
	) as a
	group by a.id_filmu
	)
Return isnull(@suma,0)
end

