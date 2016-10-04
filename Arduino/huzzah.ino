//** Librerías **//
#include <OneWire.h>                
#include <DallasTemperature.h>
#include <PubSubClient.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <MCP3008.h>
#

//** Definiciones **//

//define pin connections

#define CS_PIN 14
#define CLOCK_PIN 5
#define MOSI_PIN 13
#define MISO_PIN 12
 
MCP3008 adc(CLOCK_PIN, MOSI_PIN, MISO_PIN, CS_PIN); //Se llama a la librería de MCP

#define SENSOR_PIN  4   //Se declara el pin donde se conectará la DATA

OneWire oneWire(SENSOR_PIN); //Se establece el pin declarado como bus para la comunicación OneWire
DallasTemperature DS18B20(&oneWire); //Se llama a la librería DallasTemperature

const char* host = "api.thingspeak.com"; // Tu dominio  
String ApiKey = "ZXKQ6RBIYQA6DZWG";
String path = "/update?key=" + ApiKey + "&field2=";
String pathVol = "/update?key=" + ApiKey + "&field3=";
const int httpPort = 80;


const char* ssid = "Orange-0CEC" ; //"Arduino"; //"Orange-0CEC" ;
const char* pass = "lor_=kcorQypEcg41" ; //"pepe_4523"; //"lor_=kcorQypEcg41" ;

const int timeSleep = 1 * 60; // x * 60 donde x son minutos que va dormir el micro
char temperatureString[6];
char voltageString[6];

//** Programa **//

void setup() {
  Serial.begin(115200);
  Serial.println("");                 

  WiFi.begin(ssid,pass);
  // Esperamos para que se conecte
  while (WiFi.status() != WL_CONNECTED) {
    delay(100);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  
  DS18B20.begin();      //Se inician los sensores
}

float getTemperature() {
  float temp;
  do {
    DS18B20.requestTemperatures(); 
    temp = DS18B20.getTempCByIndex(0);
    delay(100);
  } while (temp == 85.0 || temp == (-127.0));
  return temp;
}

void loop() {
  
  float temperature = getTemperature();
  dtostrf(temperature, 2, 2, temperatureString);

  WiFiClient client;
  if(!client.connect(host, httpPort)){
    Serial.println("fallo de conexion"); 
  }
  
  client.print(String("GET ") + path + temperatureString + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" + 
               "Connection: keep-alive\r\n\r\n" );

  client.stop();
  
  Serial.print("Temperature:");
  Serial.println(temperature);
  Serial.print("TemperatureString:");
  Serial.println(temperatureString);

  

  delay(30000);
  
  int val = adc.readADC(0);  // read Channel 0 from MCP3008 ADC (pin 1)
  float voltage = (val * 3.3) / 1023 ; //Conversión de adc a su correspondiente voltaje 3.3 = Vref
  
  dtostrf(voltage, 2, 2, voltageString);

   if(!client.connect(host, httpPort)){
    Serial.println("fallo de conexion"); 
  }
  
  client.print(String("GET ") + pathVol + voltageString + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" + 
               "Connection: keep-alive\r\n\r\n" );
  
  Serial.print("Luz:");
  Serial.println(val);
  Serial.print("Voltage:");
  Serial.println(voltage);
  Serial.print("VoltageString:");
  Serial.println(voltageString);
  
  delay(1000); //Se provoca una parada de 1 segundo antes de la próxima lectura
  ESP.deepSleep(1000000*timeSleep);
                

}



