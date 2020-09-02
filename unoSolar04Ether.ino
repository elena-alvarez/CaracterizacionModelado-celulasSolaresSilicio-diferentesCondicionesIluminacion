/***************************************
 * unoSolar04Ether
 * 
 * modifica la toma de muestras para optimizar maximo de puntos a maxima tension
 */

#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xDF, 0x8E, 0xE06
};
//Compatible con las direcciones de red
IPAddress ip(192, 168, 1, 177);
EthernetServer server(80);

void CortocircuitaPlacaSolar(boolean);
void EnviaDatosCliente(EthernetClient);


#define NUMERO_MUESTRAS 256
int numeroMuestras = NUMERO_MUESTRAS;
unsigned int arrCorriente[NUMERO_MUESTRAS];
unsigned int arrTension  [NUMERO_MUESTRAS];
char  cadenaF[16]=" ";
unsigned int numeroSerie=0;
float corrienteF;
float tensionF;

void CortocircuitaPlacaSolar (boolean conmuta){
  if (conmuta){ 
     digitalWrite(3,  LOW);
     delay(5);
     digitalWrite(13, HIGH);
     digitalWrite(2,  HIGH);
  }
  else{
     digitalWrite(2,  LOW);
     digitalWrite(13, LOW);
     digitalWrite(3,  HIGH);
  }
}

void setup()
{
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(13, OUTPUT);
  analogReference(EXTERNAL);
  CortocircuitaPlacaSolar(true);
  Serial.println("Comienza");

  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  server.begin();
  Serial.print("Servidor en direccion ");
  Serial.println(Ethernet.localIP());
}

void loop()
{
  unsigned long microsAntes;
  unsigned long microsDespues;
  unsigned long ultimaMuestraCorriente;
  unsigned int tEspera = 0;
  int          nMuestra=0;
  int          incremento=1;
  
  
  unsigned int corriente;
  unsigned int tension;
  unsigned int valorAnteriorCorriente=0;

  for (int i = 0; i<NUMERO_MUESTRAS; i++){
        arrTension[i]   = 0L;
        arrCorriente[i] = 0L;
  }

  EthernetClient client = server.available();
  /****************
  * Lectura de datos en crudo
  **/
  // Solo tomamos muestras si tenemos cliente
  if(client){ 
     numeroSerie++;
     CortocircuitaPlacaSolar(false);
     microsAntes = micros();

     ultimaMuestraCorriente = 1;  //Para que entre en el bucle
     nMuestra               = 0;  //Primera muestra que vamos a tomar
     incremento             = 1;  //Incremento inicial para llenar el 
                                  // array de muestras
     /*
      * Tomaremos muestras hasta tener corriente cero.
      * Si antes de tener corriente cero, hemos llenado el array de muestras
      * volveremos a recorrer el array de muestras
      * insertando las nuevas tomas en incrementos de 2,3,4, ... y así
      * sucesivamente hasta llegar a un máximo de 20 pasadas para no provocar
      * un time out en el cliente.
      */
     while (ultimaMuestraCorriente || (nMuestra<5)) {
        arrTension  [nMuestra] = analogRead(A1);
        ultimaMuestraCorriente = arrCorriente[nMuestra] = analogRead(A2);
        nMuestra +=incremento;
        if (nMuestra > NUMERO_MUESTRAS-1){
          incremento++;
          nMuestra=incremento-1;
        }
        if (incremento == 15) break;
        delay(incremento*5);      
     }
     
     
     CortocircuitaPlacaSolar(true);
     microsDespues = micros();
     Serial.print(F("Numero Muestras: "));
     Serial.println(nMuestra);

     Serial.print(F("Incremento: "));
     Serial.println(incremento);

     Serial.print(F("ultimaMuestraCorriente: "));
     Serial.println(ultimaMuestraCorriente);
     
  }
  
  /****
   ** Ajuste de valores en crudo a valores reales
   * y presentacion de los mismos
   **
  */
  int presentaColumnas=0;

  if(presentaColumnas){
   Serial.println("Corriente Tension");
   for (int i = 0; i<NUMERO_MUESTRAS; i++){
     //Tension de referencia a 3.2 V
     // 
     //3.3/1024 = 3.22265 exp -3  Para Vref = 3.3V

     /******************************************
      * Medimos caida de tension en una R de 1 Ohmio 
      * a la salida de un aplificador con Av=10
      * Valor Real de la corriente. Av=10, R=1 ohmio
      * Por ello dividimos por 10 
      */
     corrienteF = arrCorriente[i]*3.22265*0.0001;
     /********************************/
     /*  Valor Real de Tension:
      *   Divisor de tension 
      *   Vi Tension en la Placa
      *   Vo Tension medida
      *   R1=56.67 Mohm
      *   R2=10 Mohm
      *   Vo=R2/(R1+R2)  * Vi
      *   Vi=(R1+R2)/R2  * Vo
      *   
      *   Vi=(56.67+10)/10 *Vo
      *   Vi=66.67/10 * Vo
      *   Vi = 6.667*Vo
      */
     tensionF   = arrTension[i]*3.22265*0.001*6.667;

     //Presentamos resultados
     dtostrf(corrienteF,-9,5,cadenaF);//dato, anchoTotal, decimales, buffer
     Serial.print(cadenaF);
     Serial.print(" ");
     dtostrf(tensionF,-9,5,cadenaF);
     Serial.println(cadenaF);
   }
  }
  

  
  // listen for incoming clients
  
  if (client) {
    Serial.println("new client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.write(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          //client.println("Refresh: 5");  // refresh the page automatically every 5 sec
          client.println();
          //client.println("<!DOCTYPE HTML>");
          //client.println("<html><body>");
          // output the value of each analog input pin
          EnviaDatosCliente(client);
          //client.println("</body></html>");
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
    Serial.println("client disconnected");
  }
  else {
    /*******************
    //Para octave
    Serial.print("corriente");
    Serial.print(numeroSerie);
    Serial.print("=[");
    for (int i = 0; i<2; i++){
      corrienteF = arrCorriente[i]*3.22265*0.0001;
      dtostrf(corrienteF,-9,5,cadenaF);//dato, anchoTotal, decimales, buffer
      Serial.print(cadenaF);
      Serial.print(" ");
    }
    Serial.println("];<br>");

    Serial.print("tension");
    Serial.print(numeroSerie);
    Serial.print("=[");
    for (int i = 0; i<2; i++){
      tensionF   = arrTension[i]*3.22265*0.001*6.667;
      dtostrf(tensionF,-9,5,cadenaF);
      Serial.print(cadenaF);
      Serial.print(" ");

    }
    Serial.println("];");
    ************/
  }

  //delay(10000);
  
}

void EnviaDatosCliente(EthernetClient cliente){
  //cliente.println("Hola");
  //Para octave
  //cliente.print("corriente");
  //cliente.print(numeroSerie);
  cliente.print("[");
  for (int i = 1; i<NUMERO_MUESTRAS; i++){
    corrienteF = arrCorriente[i]*3.22265*0.0001;
    dtostrf(corrienteF,-9,5,cadenaF);//dato, anchoTotal, decimales, buffer
    cliente.print(cadenaF);
    cliente.print(" ");
  }
  cliente.println(";");

  //cliente.print("tension");
  //cliente.print(numeroSerie);
  cliente.print(" ");
  for (int i = 1; i<NUMERO_MUESTRAS; i++){
    tensionF   = arrTension[i]*3.22265*0.001*6.667;
    dtostrf(tensionF,-9,5,cadenaF);
    cliente.print(cadenaF);
    cliente.print(" ");

  }
  cliente.println("];");

}
