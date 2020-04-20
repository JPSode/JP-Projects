create sequence seq_myseq
start with 1
increment by 1;

create table KUND(
    persnr varchar2(11) ,
    username varchar2(8) ,
    passwd varchar2(20) ,
    fnamn varchar2(15) not null,
    enamn varchar2(20) not null,
    kredittyp varchar2(30) ,
    telnr varchar2(11) 

);



create table KUNDORDER(
ordnr number(9),
persnr varchar2 (11) not null ,
datum date default sysdate not null

);
insert into KUNDORDER
values(seq_myseq.nextval,'871205-9536',sysdate);

commit;


create table VARUGRUPP(
    vgnr number(9),
    vgnamn varchar(40) not null
);


create table ARTIKEL(
    artnr number(9),
    vgnr number(9) not null,
    artnamn varchar2(30) not null,
    pris number(6) not null
);

delete from kundorder
where ordnr=1;

commit;

create table ARTIKELBILD (
    bildnr number(9) ,
    artnr number(9) not null,
    filtyp varchar2(24) ,
    width varchar2(10) not null,
    height varchar2(10) not null,
    filepath varchar2(100) not null
);

create table KUNDVAGN(
    radnr number(9) ,
    ordnr number(9) not null ,
    artnr number(9) not null,
    antal number(6) not null
);

insert into KUNDVAGN
values(seq_myseq.nextval,1,1,4);

insert into KUNDVAGN
values(seq_myseq.nextval,1,3,6);

commit;
alter table KUND
add CONSTRAINT persnr_pk primary key(persnr)
add CONSTRAINT username_uq UNIQUE(username)
add CONSTRAINT passwd_uq UNIQUE(passwd)
add constraint kredittyp_ck check(kredittyp in( 'hög', 'medel','låg'))
;
alter table KUNDORDER
add CONSTRAINT kundorder_ordnr_pk primary key(ordnr)
add constraint kundorder_persnr_fk FOREIGN key (persnr) references KUND(persnr)
;
alter table VARUGRUPP
    add constraint varugrupp_vgnr_pk primary key(vgnr)


;
alter table ARTIKEL
add CONSTRAINT artikel_artnr_pk primary key(artnr)
add CONSTRAINT artikel_vgnr_fk FOREIGN key (vgnr) references VARUGRUPP(vgnr)
;
alter table ARTIKELBILD
add constraint artikelbild_bildnr_pk primary key(bildnr)
add constraint artikelbild_artnr_fk foreign key (artnr)REFERENCES ARTIKEL(artnr)
add constraint artikelbild_filtyp_ck check(filtyp='.jpg'or filtyp='.gif')
;
alter table KUNDVAGN 
add constraint kundvagn_radnr_pk primary key(radnr)
add constraint kundvagn_ordnr_fk foreign key(ordnr)references KUNDORDER(ordnr)
add constraint kundvagn_artnr_fk foreign key (artnr)references ARTIKEL(artnr)
;



commit;










select username,passwd,fnamn,enamn,yrke,regdatum,årslön
from KUND
order by KUND asc;


select count(*)
from KUND;


select username,passwd,fnamn,enamn,yrke,regdatum,årslön
from KUND
where årslön< 300000;

select avg(nvl(årslön,0)) Medellön
from kund;

select username,fnamn,enamn
from KUND
where nvl(årslön,0)<355300;

select  upper(fnamn),upper(enamn)
from KUND
where lower(enamn) like'%s%';


select lower(fnamn)fnamn,lower(enamn)enamn,lower(nvl(yrke,'Arbetsfri'))Yrke
from KUND
where lower(fnamn)like'%s';


select initcap(nvl(yrke,'Arbetsfri'))Yrke,count(nvl(yrke,'Arbetsfri'))Antal
from KUND
group by Yrke
order by yrke asc;


select initcap(fnamn)||' '||initcap(enamn) as KUNDNAMN
from KUND;

select count(*)inloggad
from KUND
where username='King25'
and passwd='asdf1234';

select username,passwd,regdatum
from KUND
where regdatum<'01-Jan-2000';

select username,passwd,regdatum
from KUND
where regdatum between '01-Jan-2001' and '1-Oct-2003';


select username,passwd,fnamn,enamn
from KUND
where lower(fnamn) not like 'roger'
and initcap(enamn) = 'Nyberg'
or lower(enamn) = 'kvist'
and initcap(fnamn) not like 'Roger';


select fnamn,enamn,årslön
from KUND
where årslön =(select max(årslön) from KUND);


select fnamn,enamn,årslön
from KUND
where årslön =(select min(årslön) from KUND)
and årslön is not null;

select fnamn,enamn
from KUND
where yrke is null;

select username,fnamn,enamn,nvl(årslön,0)årslön
from KUND
where nvl(årslön,0) < (select avg(nvl(årslön,0)) from KUND)
;


select k.knr,k.fnamn,k.enamn, count(ko.ordnr)Antal_ordrar
from kund k,kundorder ko
where k.knr=ko.knr
group by k.knr,k.fnamn,k.enamn
order by knr asc;


select knr,fnamn,enamn
from kund
where knr in(select knr from kundorder where ordnr in 
(select ordnr from orderrad where artnr in
(select artnr from artikel where vgnr in
(select vgnr from varugrupp 
where lower(vgnamn)='skäggvård' 
or lower(vgnamn)='bondgård'
)))) order by knr asc;



select kund.knr,kund.fnamn,kund.enamn
from kund,kundorder,orderrad,artikel,varugrupp
where kund.knr = kundorder.knr
and kundorder.ordnr=orderrad.ordnr
and orderrad.artnr=artikel.artnr
and artikel.vgnr=varugrupp.vgnr
where lower(vgnamn) ='bondgård'
or lower(vgnamn)='skäggvård';


select distinct kund.knr,kund.fnamn,kund.enamn
from kund,kundorder,orderrad,artikel,varugrupp
where kund.knr = kundorder.knr
and kundorder.ordnr=orderrad.ordnr
and orderrad.artnr=artikel.artnr
and artikel.vgnr=varugrupp.vgnr
and vgnamn in('skäggvård', 'bondgård')
order by knr asc;


select k.knr,k.fnamn,k.enamn,sum(a.pris*o.antal)Summa
from kund k,kundorder ko, orderrad o,artikel a
where k.knr = ko.knr
and ko.ordnr=o.ordnr
and o.artnr=a.artnr
group by k.knr,k.fnamn,k.enamn
order by knr asc;


select k.knr,k.fnamn,k.enamn,round(sum(a.pris*o.antal))Summa
from kund k,kundorder ko, orderrad o,artikel a
where k.knr = ko.knr
and ko.ordnr=o.ordnr
and o.artnr=a.artnr
group by k.knr,k.fnamn,k.enamn
order by round(sum(a.pris*o.antal)) desc;


select k.knr,k.fnamn,k.enamn,round(sum(a.pris*o.antal))Summa
from kund k,kundorder ko, orderrad o,artikel a
where k.knr = ko.knr
and ko.ordnr=o.ordnr
and o.artnr=a.artnr
having round(sum(a.pris*o.antal))>1500
group by k.knr,k.fnamn,k.enamn
order by round(sum(a.pris*o.antal)) desc;

select initcap(fnamn)"FÖRNAMN",initcap(enamn)"EFTERNAMN"
from kund
where knr not in(select knr from kundorder);


select vg.vgnamn,max(a.pris)Dyrast
from varugrupp vg,artikel a
where vg.vgnr=a.vgnr
group by vg.vgnamn
order by vgnamn asc;

select artnr,initcap(path)
||initcap(bildnr)||'.'||initcap(filtyp) as "sökväg"
from artikelbild;

select fnamn,enamn
from kund
where knr in(select knr from kundorder where datum> to_date('2004-01-01','YYYY-MM-DD'));

select * from(
select o.ordnr,sum(o.antal*a.pris)"SUMMA"
from orderrad o,artikel a
where o.artnr=a.artnr
group by o.ordnr
order by sum(o.antal*a.pris)desc
)where rownum=1;

declare 
v_regnr fordon.regnr%type;
v_tillverkare fordon.tillverkare%type;
v_modell fordon.modell%type;

begin
select regnr,tillverkare,modell 
into v_regnr,v_tillverkare,v_modell
from fordon
where pnr in(select pnr from bilägare where pnr='19650823-7999');

dbms_output.put_line('regnr:'||v_regnr);
dbms_output.put_line('tillverkare:'||v_tillverkare);
dbms_output.put_line('modell:'||v_modell);

end;


declare 
v_regnr fordon.regnr%type;
v_tillverkare fordon.tillverkare%type;
v_modell fordon.modell%type;

begin
select regnr,tillverkare,modell 
into v_regnr,v_tillverkare,v_modell
from fordon
where pnr in(select pnr from bilägare where pnr='19540201-4428');

dbms_output.put_line('regnr:'||v_regnr);
dbms_output.put_line('tillverkare:'||v_tillverkare);
dbms_output.put_line('modell:'||v_modell);

exception
when others then
dbms_output.put_line('Något blev fel!');

end;

declare 
v_regnr fordon.regnr%type;
v_tillverkare fordon.tillverkare%type;
v_modell fordon.modell%type;
v_error varchar2(100);
v_code number(6);


begin



select regnr,tillverkare,modell 
into v_regnr,v_tillverkare,v_modell
from fordon
where pnr in(select pnr from bilägare where pnr='19540201-4428');


dbms_output.put_line('regnr:'||v_regnr);
dbms_output.put_line('tillverkare:'||v_tillverkare);
dbms_output.put_line('modell:'||v_modell);

exception
when others then
v_error:=sqlerrm;
v_code:= sqlcode;
dbms_output.put_line('fel:'||v_code||'felmeddelande:'||v_error);

end;

declare

cursor c_bilägarålder  is select initcap(fnamn)"Förnamn",initcap(enamn)"Efternamn",to_date(substr(pnr,1,8),'YYYY-MM-DD')"Födelsedata"from bilägare;
v_fnamn bilägare.fnamn%type;
v_enamn bilägare.fnamn%type;
v_födelsedata date;
v_ålder number(3,1);
begin
if not c_bilägarålder%isopen then
open c_bilägarålder;
end if;
loop
fetch c_bilägarålder
into v_fnamn,v_enamn,v_födelsedata;
exit when c_bilägarålder%notfound;
v_ålder:=(sysdate-v_födelsedata)/365;
dbms_output.put_line(v_fnamn||','||v_enamn||','||v_ålder);
end loop;
close c_bilägarålder;
end;



declare

cursor c_bilar is select b.pnr,b.fnamn,b.enamn,count(f.pnr) from bilägare b,fordon f
where b.pnr=f.pnr
group by b.pnr,b.fnamn,b.enamn;
v_personnummer bilägare.pnr%type;
v_förnamn bilägare.fnamn%type;
v_efternamn  bilägare.enamn%type;
v_antal fordon.pnr%type;




begin
if not c_bilar%isopen then
open c_bilar;
end if;
loop 
fetch c_bilar
into v_personnummer,v_förnamn,v_efternamn,v_antal;
exit when c_bilar%notfound;
if  v_antal > 1 then
dbms_output.put_line(v_personnummer||','||v_förnamn||','||v_efternamn||' äger: '||v_antal||' bilar');
else
dbms_output.put_line(v_personnummer||','||v_förnamn||','||v_efternamn||' äger: '||v_antal||' bil');

end if;
end loop;
close c_bilar;
end;
/




declare
cursor c_fartdåre is select b.pnr,b.fnamn,b.enamn,f.regnr,f.tillverkare,f.modell from bilägare b,fordon f
where f.hk>=200
and b.pnr=f.pnr;

v_rec c_fartdåre%rowtype;
begin
if not c_fartdåre%isopen then
open c_fartdåre;
end if;

loop

fetch c_fartdåre
into v_rec;
exit when c_fartdåre%notfound;

insert into fartdåre(pnr,fnamn,enamn,regnr,tillverkare,modell)
values(v_rec.pnr,v_rec.fnamn,v_rec.enamn,v_rec.regnr,v_rec.tillverkare,v_rec.modell);
end loop;
close c_fartdåre;

commit;
dbms_output.put_line('Kopieringen är klar!');
end;