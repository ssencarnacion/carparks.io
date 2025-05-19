#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>

// WiFi credentials
const char* ssid = "WIFI SSID HERE";
const char* password = "WIFI PASSWORD";

// Firebase credentials
const char* API_KEY = "FIREBASE API KEY";
const char* USER_EMAIL = "USER EMAIL";
const char* USER_PASSWORD = "PASSWORD";
const char* DATABASE_URL = "https://carparks-c719c-default-rtdb.asia-southeast1.firebasedatabase.app";


// Firebase components
UserAuth user_auth(API_KEY, USER_EMAIL, USER_PASSWORD);
FirebaseApp app;
WiFiClientSecure ssl_client;
using AsyncClient = AsyncClientClass;
AsyncClient aClient(ssl_client);
RealtimeDatabase Database;

// HC-SR04 pins
#define TRIG_PIN_1 D6
#define ECHO_PIN_1 D5
#define TRIG_PIN_2 D9
#define ECHO_PIN_2 D8

// Distance thresholds
#define MAX_OCCUPIED_CM 200
#define MIN_OCCUPIED_CM 0

// Timer for periodic Firebase sending
unsigned long lastSendTime = 0;
const unsigned long sendInterval = 10000;  // 10 seconds

// Firebase callback
void processData(AsyncResult &aResult);

void setup() {
  Serial.begin(9600);
  // Sensor pin setup
  pinMode(TRIG_PIN_1, OUTPUT);
  pinMode(ECHO_PIN_1, INPUT);
  pinMode(TRIG_PIN_2, OUTPUT);
  pinMode(ECHO_PIN_2, INPUT);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println(" connected!");

  // Print IP address
  Serial.print("ESP IP Address: ");
  Serial.println(WiFi.localIP());

  // Setup SSL
  ssl_client.setInsecure();
  ssl_client.setTimeout(1000);
  ssl_client.setBufferSizes(4096, 1024);

  // Initialize Firebase
  initializeApp(aClient, app, getAuth(user_auth), processData, "🔐 authTask");
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}

void loop() {
  app.loop();

  if (app.ready()) {
    unsigned long currentTime = millis();
    if (currentTime - lastSendTime >= sendInterval) {
      lastSendTime = currentTime;

      // Read distances
      float dist1 = getDistance(TRIG_PIN_1, ECHO_PIN_1);
      float dist2 = getDistance(TRIG_PIN_2, ECHO_PIN_2);

      // Determine occupancy
      bool occupied1 = (dist1 > MIN_OCCUPIED_CM && dist1 <= MAX_OCCUPIED_CM);
      bool occupied2 = (dist2 > MIN_OCCUPIED_CM && dist2 <= MAX_OCCUPIED_CM);

      // Print to Serial
      Serial.printf("Sensor 1: %.2f cm - %s\n", dist1, occupied1 ? "OCCUPIED" : "EMPTY");
      Serial.printf("Sensor 2: %.2f cm - %s\n", dist2, occupied2 ? "OCCUPIED" : "EMPTY");
      Serial.println("-----------------------------");

      // Send to Firebase
      Database.set<float>(aClient, "/demo/slot1", dist1, processData, "RTDB_Send_Slot1");
      Database.set<float>(aClient, "/demo/slot2", dist2, processData, "RTDB_Send_Slot2");
    }
  }
}

// Distance calculation
float getDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 30000);  // Timeout after 30ms
  if (duration == 0) return 999;  // No echo
  return duration * 0.0343 / 2;
}

// Firebase callback handler
void processData(AsyncResult &aResult) {
  if (!aResult.isResult()) return;

  if (aResult.isEvent())
    Firebase.printf("Event task: %s, msg: %s, code: %d\n",
                    aResult.uid().c_str(),
                    aResult.eventLog().message().c_str(),
                    aResult.eventLog().code());

  if (aResult.isDebug())
    Firebase.printf("Debug task: %s, msg: %s\n",
                    aResult.uid().c_str(),
                    aResult.debug().c_str());

  if (aResult.isError())
    Firebase.printf("Error task: %s, msg: %s, code: %d\n",
                    aResult.uid().c_str(),
                    aResult.error().message().c_str(),
                    aResult.error().code());

  if (aResult.available())
    Firebase.printf("task: %s, payload: %s\n",
                    aResult.uid().c_str(),
                    aResult.c_str());
}
