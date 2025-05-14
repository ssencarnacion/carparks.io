#include <ESP8266WiFi.h>
#include <ThingSpeak.h>

// WiFi credentials
const char* ssid = "Jed's iphone";
const char* password = "123456789";

// ThingSpeak settings
const char* apiKey = "4PRJGB46A8EALOTY";
unsigned long channelID = 2945987;
const char* server = "api.thingspeak.com";

WiFiClient client;

// HC-SR04 pins
#define TRIG_PIN_1 D6
#define ECHO_PIN_1 D5
#define TRIG_PIN_2 D9
#define ECHO_PIN_2 D8

// Distance threshold for parking occupancy
#define MAX_OCCUPIED_CM 50
#define MIN_OCCUPIED_CM 0

void setup() {
  Serial.begin(9600);
  pinMode(TRIG_PIN_1, OUTPUT);
  pinMode(ECHO_PIN_1, INPUT);
  pinMode(TRIG_PIN_2, OUTPUT);
  pinMode(ECHO_PIN_2, INPUT);

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" connected!");
  ThingSpeak.begin(client);
}

void loop() {
  float dist1 = getDistance(TRIG_PIN_1, ECHO_PIN_1);
  float dist2 = getDistance(TRIG_PIN_2, ECHO_PIN_2);

  // Check occupancy
  bool occupied1 = (dist1 > MIN_OCCUPIED_CM && dist1 <= MAX_OCCUPIED_CM);
  bool occupied2 = (dist2 > MIN_OCCUPIED_CM && dist2 <= MAX_OCCUPIED_CM);

  Serial.print("Sensor 1: ");
  Serial.print(dist1);
  Serial.print(" cm - ");
  Serial.println(occupied1 ? "OCCUPIED" : "EMPTY");

  Serial.print("Sensor 2: ");
  Serial.print(dist2);
  Serial.print(" cm - ");
  Serial.println(occupied2 ? "OCCUPIED" : "EMPTY");

  Serial.println("-----------------------------");

  // Send raw distances to ThingSpeak fields
  ThingSpeak.setField(1, dist1);
  ThingSpeak.setField(2, dist2);

  // Optionally also send binary occupancy status (1 = occupied, 0 = empty)
  ThingSpeak.setField(3, occupied1 ? 1 : 0);
  ThingSpeak.setField(4, occupied2 ? 1 : 0);

  int status = ThingSpeak.writeFields(channelID, apiKey);
  if (status == 200) {
    Serial.println("Data sent to ThingSpeak.");
  } else {
    Serial.print("Error sending data: ");
    Serial.println(status);
  }

  delay(15000); // Respect ThingSpeak free tier rate limit
}

// Reusable distance function
float getDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 30000);
  if (duration == 0) return 999;  // Timeout → no reading
  return duration * 0.0343 / 2;
}
