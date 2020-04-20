create table bankkund(
    pnr varchar2(11) not null,
    fnamn varchar2(25) not null,
    enamn varchar2(25) not null,
    passwd varchar2(16) not null
);
create table kontotyp(
    ktnr number(6) not null,
    ktnamn varchar2(20) not null,
    ränta number(5,2) not null
);
create table ränteändring(
    rnr number(6) not null,
    ktnr number(6) not null,
    ränta number(5,2) not null,
    rnr_datum date not null
);
create table konto(
    knr number(8) not null,
    ktnr number(6) not null,
    regdatum date not null,
    saldo number(10,2)
);
create table kontoägare(
    radnr number(9) not null,
    pnr varchar2(11) not null,
    knr number(8) not null
);
create table uttag(
    radnr number(9) not null,
    pnr varchar2(11) not null,
    knr number(8) not null,
    belopp number(10,2),
    datum date not null
);
create table insättning(
    radnr number(9) not null,
    pnr varchar2(11) not null,
    knr number(8) not null,
    belopp number(10,2),
    datum date not null
);
create table överföring(
    radnr number(9) not null,
    pnr varchar2(11) not null,
    från_knr number(8) not null,
    till_knr number(8) not null,
    belopp number(10,2),
    datum date not null
);

alter table bankkund
add CONSTRAINT pnr_pk primary key(pnr);

alter table kontotyp
add constraint ktnr_pk primary key(ktnr);

alter table ränteändring
add constraint rnr_pk primary key(rnr)
add constraint ktnr_fk foreign key (ktnr) references kontotyp(ktnr);

alter table konto
add constraint knr_pk primary key(knr)
add constraint konto_ktnr_fk foreign key(ktnr)references kontotyp(ktnr);

alter table kontoägare
add constraint radnr_pk primary key(radnr)
add constraint kontoägare_pnr_fk foreign key(pnr)references bankkund(pnr)
add constraint kontoägare_knr_fk foreign key (knr)references konto(knr);

alter table uttag
add constraint uttag_radnr_fk foreign key(radnr)references kontoägare(radnr)
add constraint uttag_pnr_fk foreign key (pnr)references bankkund(pnr)
add constraint uttag_knr_fk foreign key (knr) references konto(knr);

alter table insättning
add constraint in_radnr_fk foreign key (radnr) references kontoägare(radnr)
add constraint in_pnr_fk foreign key (pnr) references bankkund(pnr)
add constraint in_knr_fk foreign key (knr) references konto(knr);

alter table överföring 
add constraint över_radnr_fk foreign key(radnr) references kontoägare(radnr)
add constraint över_pnr_fk foreign key (pnr) references bankkund(pnr)
add constraint från_knr_fk foreign key(från_knr)references konto(knr)
add constraint till_knr_fk foreign key(till_knr) references konto(knr);

commit;

create or replace trigger biufer_bankkund
before insert or update
of passwd
on bankkund
for each row
when (length(new.passwd)>6 or length(new.passwd)<6)
begin

raise_application_error(-20001,'Lösenordet måste vara exakt 6 tecken!');

end;
/

create or replace procedure do_bankkund(
    p_pnr in bankkund.pnr%type,
    p_fnamn in bankkund.fnamn%type,
    p_enamn in bankkund.enamn%type,
    p_passwd in bankkund.passwd%type
)
as
begin
insert into bankkund(pnr,fnamn,enamn,passwd)
values(p_pnr,p_fnamn,p_enamn,p_passwd);
commit;
end;


create sequence radnr_seq
start with 1
increment by 1;

create or replace function logga_in(
    p_pnr  bankkund.pnr%type,
    p_passwd bankkund.passwd%type 
)

return number
as
v_resultat number(1);
begin
select 1
into v_resultat
from bankkund
where pnr = p_pnr
and passwd = p_passwd;
return 1;
exception
when no_data_found then
return 0;
end;
/

create or replace function get_saldo(
    p_knr  konto.knr%type
)

return number
as
v_resultat number(6);
begin
select saldo
into v_resultat
from konto
where knr = p_knr;

return v_resultat;

end;
/

create or replace function get_behörighet(
    p_pnr  kontoägare.pnr%type,
    p_knr kontoägare.knr%type
)

return number
as
v_resultat number(1);
begin
select count(radnr)
into v_resultat
from kontoägare
where pnr = p_pnr
and knr = p_knr;
return v_resultat;


end;
/


create or replace trigger aifer_insättning
after insert 
on insättning
for each row
when(new.belopp is not null)
begin
update konto 
set saldo = saldo + :new.belopp
where knr = :new.knr ;



end;
/



create or replace trigger bifer_uttag
before insert 
on uttag
for each row


begin


if get_saldo(:new.knr)<:new.belopp then
raise_application_error(-20001,'Kontot har inte täckning');
end if;


end;
/


create or replace trigger aifer_uttag
after insert 
on uttag
for each row
when(new.belopp is not null)
begin
update konto 
set saldo = saldo - :new.belopp
where knr = :new.knr ;


end;
/



create or replace trigger bifer_överföring
before insert or update
on överföring
for each row


begin

if get_saldo(:new.från_knr)<:new.belopp then
raise_application_error(-20001,'Kontot har inte täckning');
end if;


end;
/



create or replace trigger aifer_överföring
after insert 
on överföring
for each row
when(new.belopp is not null)
begin
update konto 
set saldo = saldo + :new.belopp
where knr = :new.till_knr;
update konto
set saldo = saldo - :new.belopp
where knr= :new.från_knr ;


end;
/


create or replace procedure do_insättning(
    p_radnr in insättning.radnr%type,
    p_pnr in insättning.pnr%type,
    p_knr in insättning.knr%type,
    p_belopp in insättning.belopp%type
)

as


begin


insert into insättning(radnr,pnr,knr,belopp,datum)
values(p_radnr,p_pnr,p_knr,p_belopp,sysdate);
commit;

dbms_output.put_line('Ditt saldo är: '|| get_saldo(p_knr));
end;



create or replace procedure do_uttag(
    p_radnr in uttag.radnr%type,
    p_pnr in uttag.pnr%type,
    p_knr in uttag.knr%type,
    p_belopp in insättning.belopp%type
)

as
obehörig exception;
begin
if(get_behörighet(p_pnr,p_knr)=0)then
raise obehörig;
end if;


insert into uttag(radnr,pnr,knr,belopp,datum)
values(p_radnr,p_pnr,p_knr,p_belopp,sysdate);
commit;
dbms_output.put_line('Ditt saldo är: '|| get_saldo(p_knr));
exception
when obehörig then
raise_application_error(-20007,'obehörig!');

end;



create or replace procedure do_överföring(
    p_radnr in överföring.radnr%type,
    p_pnr in överföring.pnr%type,
    p_från_knr in överföring.från_knr%type,
    p_till_knr in överföring.till_knr%type,
    p_belopp in överföring.belopp%type
)

as
obehörig exception;
begin
if(get_behörighet(p_pnr,p_från_knr)=0)then
raise obehörig;
end if;


insert into överföring(radnr,pnr,från_knr,till_knr,belopp,datum)
values(p_radnr,p_pnr,p_från_knr,p_till_knr,p_belopp,sysdate);
commit;
dbms_output.put_line('Ditt saldo på kontot du skickat till är: '|| get_saldo(p_till_knr));
dbms_output.put_line('Ditt saldo på kontot du skickat från är: '|| get_saldo(p_från_knr));
exception
when obehörig then
raise_application_error(-20007,'obehörig!');

end;














create or replace function get_behörighet(
    p_radnr  gymbehörighet.radnr%type,
    p_rfid gymbehörighet.rfid%type,
    p_gymid gymbehörighet.gymid%type
)

return number
as
v_resultat number(1);
begin
select count(radnr)
into v_resultat
from gymbehörighet
where rfid = p_rfid
and gymid = p_gymid;
return v_resultat;


end;
/


