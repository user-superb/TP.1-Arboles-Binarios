program Project1;
uses crt;
const
  FIN_DUENO = 90909090;
  FIN_MASCOTA = '0';

type
  fecha = record
    dia: 1..31;
    mes: 1..12;
    ano: integer;
  end;

  mascota = record
    iden: string[255];
    tipo: string[255];
    peso: real;
    ingreso: fecha;
    cantInterv: integer;
  end;

  listaMascotas = ^nodoMascota;

  nodoMascota = record
    dato: mascota;
    sig: listaMascotas;
  end;

  dueno = record
    dni: longint;
    nombreApellido: string[255];
    direccion: string[255];
    mascotas: listaMascotas;
  end;


  arbolDuenos = ^nodoDueno;

  nodoDueno = record
    dato: dueno;
    iz: arbolDuenos;
    de: arbolDuenos;
  end;

{////////// punto a //////////}

procedure insertarNodoMascota(var l: listaMascotas; d: mascota);
var
  nue: listaMascotas;
begin
  new(nue);
  nue^.dato:= d;
  nue^.sig:= l;
  l:= nue;
end;

procedure insertarNodoArbol(var a: arbolDuenos; d: dueno);
begin
  if (a = NIL) then
     begin
       new(a);
       a^.dato:= d;

       a^.iz:= NIL;
       a^.de:= NIL;
     end
  else
      begin
        if (d.dni < a^.dato.dni) then
           insertarNodoArbol(a^.iz, d)
        else if (d.dni > a^.dato.dni) then
           insertarNodoArbol(a^.de, d);
      end;
end;

procedure leerMascota(var m: mascota);

begin
  writeln('Nueva Mascota (FIN = 0)');
  write('Identificacion: ');
  readln(m.iden);
  if not(m.iden = FIN_MASCOTA) then
     begin
          writeln('Fecha ingreso: ');
                         write('        Dia: ');
                         readln(m.ingreso.dia);
                         write('        Mes: ');
                         readln(m.ingreso.mes);
                         write('        Ano: ');
                         readln(m.ingreso.ano);
          write('Peso: ');
          readln(m.peso);
          write('Tipo: ');
          readln(m.tipo);
          write('Cantidad de Intervenciones: ');
          readln(m.cantInterv);
     end;
end;

procedure leerDueno(var d: dueno);
var
  m: mascota;
begin
  d.mascotas:= NIL;

  writeln('[Nuevo Dueno] (FIN = 90909090)');
  write('DNI: ');
  readln(d.dni);
  if not(d.dni = FIN_DUENO) then
     begin
       write('Nombre y Apellido: ');
       readln(d.nombreApellido);
       write('Direccion: ');
       readln(d.direccion);
       leerMascota(m);
       while not(m.iden = FIN_MASCOTA) do
             begin
                  insertarNodoMascota(d.mascotas, m);
                  leerMascota(m);
             end;
     end;
end;

procedure leerDatos(var a: arbolDuenos);
var
  d: dueno;
begin
  leerDueno(d);
  while (d.dni <> FIN_DUENO) do
        begin
          insertarNodoArbol(a, d);

          writeln();
          leerDueno(d);
        end;
end;

{/////////// UTILS /////////////}

procedure imprimirMascotas(l: listaMascotas);
begin
  while (l <> NIL) do
        begin
          writeln('  IDENTIFICACION: ', l^.dato.iden);
          writeln('  FECHA INGRESO: ', l^.dato.ingreso.dia, '/', l^.dato.ingreso.mes, '/', l^.dato.ingreso.ano);
          writeln('  PESO: ', l^.dato.peso:0:2,' KG');
          writeln('  TIPO: ', l^.dato.tipo);
          writeln('  CANTIDAD INTERVENCIONES: ', l^.dato.cantInterv);
          writeln('------------');
          l:= l^.sig;
        end;
end;

procedure imprimirArbol(a: arbolDuenos);
begin
  if (a <> NIL) then
     begin
          imprimirArbol(a^.iz);

          writeln('DNI: ', a^.dato.dni,' . NOMBRE Y APELLIDO: ', a^.dato.nombreApellido, ' . DIRECCION: ', a^.dato.direccion);
          writeln('MASCOTAS: ');
          imprimirMascotas(a^.dato.mascotas);

          imprimirArbol(a^.de);
     end;
end;

{////////// punto b //////////}

function buscarMinimoLista(l: listaMascotas): integer;
var
  min: integer;
begin
  min:= 99999999;

  while (l <> NIL) do
        begin
          if (l^.dato.cantInterv < min) then
             min:= l^.dato.cantInterv;
          l:= l^.sig;
        end;

  buscarMinimoLista:= min;
end;

function buscarMinimoArbol(a: arbolDuenos): arbolDuenos;
var
  minArbol, aux: arbolDuenos;
  minActual, minAux: integer;
begin
  if (a = NIL) then
     buscarMinimoArbol:= NIL
  else
      begin
        minArbol:= a;
        minActual:= buscarMinimoLista(minArbol^.dato.mascotas);

        aux:= buscarMinimoArbol(a^.iz);
        if (aux <> NIL) then
           begin
                minAux:= buscarMinimoLista(aux^.dato.mascotas);
                // writeln(minActual, ' ', minAux);

                if (minAux < minActual) then
                   begin
                     minArbol:= aux;
                     minActual:= minAux;
                   end;
           end;

        aux:= buscarMinimoArbol(a^.de);
        if (aux <> NIL) then
           begin
                minAux:= buscarMinimoLista(aux^.dato.mascotas);

                if (minAux < minActual) then
                   begin
                     minArbol:= aux;
                     minActual:= minAux;
                   end;
           end;

        buscarMinimoArbol:= minArbol;
      end;
end;

procedure informarDomicilioClienteMenorInterv(a: arbolDuenos);
var
  min: arbolDuenos;
begin
  min:= buscarMinimoArbol(a);

  writeln('DIRECCION: ', min^.dato.direccion,' (MINIMO = ', buscarMinimoLista(min^.dato.mascotas), ')');
end;

{////////// punto c //////////}

procedure imprimirAcotado(a: arbolDuenos; inf, sup: longint);
begin
  if (a <> NIL) then
     begin
       if (a^.dato.dni >= inf) then
          begin
            if (a^.dato.dni <= sup) then
               begin
                 imprimirAcotado(a^.de, inf, sup);
                 writeln(' DNI: ', a^.dato.dni);
                 writeln(' NOMBRE Y APELLIDO: ', a^.dato.nombreApellido);
                 imprimirAcotado(a^.iz, inf, sup);
               end
            else
                imprimirAcotado(a^.iz, inf, sup);
          end
       else
           imprimirAcotado(a^.de, inf, sup);
     end;
end;

{////////// punto d //////////}

procedure imprimirDuenoCumpleCond(a: arbolDuenos);
CONST
  {CONDICIONES}
  PESO = 10;
  MES_INF = 1;
  MES_SUP = 3;
var
  listaAux: listaMascotas; {Recorre la lista de mascotas}
begin
  if (a <> NIL) then
     begin
       imprimirDuenoCumpleCond(a^.iz);

       listaAux:= a^.dato.mascotas;

       writeln('DUENO: ', a^.dato.nombreApellido);
       while (listaAux <> NIL) do
             begin
               if (listaAux^.dato.peso >= PESO) and (listaAux^.dato.ingreso.mes >= MES_INF) and (listaAux^.dato.ingreso.mes <= MES_SUP) then
                  writeln('            IDENTIFICACION: ', listaAux^.dato.iden, ' TIPO: ', listaAux^.dato.tipo);
               listaAux:= listaAux^.sig;
             end;
       imprimirDuenoCumpleCond(a^.de);
     end;
end;

CONST
  LIM_INF = 15000000;
  LIM_SUP = 30000000;

var
  a: arbolDuenos;
begin
  a:= NIL;

  {PUNTO A}

  leerDatos(a);
  imprimirArbol(a);

  {PUNTO B}

  writeln();
  writeln('DIRECCION DEL DUENO CON LA MASCOTA CON MENOR CANTIDAD DE INTERVENCIONES: ');
  informarDomicilioClienteMenorInterv(a);

  {PUNTO C}

  writeln();
  writeln('CUMPLEN CON EL RANGO (', LIM_INF,'..', LIM_SUP,'): ');
  imprimirAcotado(a, LIM_INF, LIM_SUP);

  {PUNTO D}

  writeln();
  writeln('DUENOS CON MASCOTAS QUE CUMPLEN LA CONDICION (PESO DE MASCOTA MAYOR QUE 10KG Y INGRESO ENTRE ENERO Y MARZO): ');
  imprimirDuenoCumpleCond(a);

  writeln();
  writeln('FIN DEL PROGRAMA');
  readln();
end.

