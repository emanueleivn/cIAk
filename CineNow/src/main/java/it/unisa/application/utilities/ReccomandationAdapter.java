package it.unisa.application.utilities;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import it.unisa.application.model.entity.Film;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class ReccomandationAdapter {
    List<Film> preferences;
    private static final String API_URL = "http://localhost:5000/recommend";
    private static final String API_KEY = "chiaveAPI";
    public ReccomandationAdapter(List<Film> preferences) {
        this.preferences = preferences;
    }
    public List<String> getRecommendations() throws IOException {
        // Preparazione della richiesta JSON
        Gson gson = new Gson();
        JsonObject requestBody = new JsonObject();

        // Converte la lista di film in JSON
        JsonArray filmArray = new JsonArray();
        for (Film film : preferences) {
            JsonObject filmJson = new JsonObject();
            filmJson.addProperty("titolo", film.getTitolo());
            filmJson.addProperty("genere", film.getGenere());
            filmJson.addProperty("regista", film.getRegista());
            filmJson.addProperty("cast", film.getCast());
            filmArray.add(filmJson);
        }

        requestBody.add("film_prenotati", filmArray);
        requestBody.addProperty("top_n", 3); // Numero massimo di film consigliati
        // Connessione HTTP
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
        conn.setDoOutput(true);
        // Invio della richiesta JSON
        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = gson.toJson(requestBody).getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        // Ricezione della risposta
        int responseCode = conn.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            throw new IOException("Errore nella comunicazione con il servizio di raccomandazione: " + responseCode);
        }
        // Lettura della risposta JSON
        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
        StringBuilder response = new StringBuilder();
        String responseLine;
        while ((responseLine = br.readLine()) != null) {
            response.append(responseLine.trim());
        }
        // Parsing della risposta JSON
        List<String> recommendedTitles = new ArrayList<>();
        JsonArray recommendations = gson.fromJson(response.toString(), JsonArray.class);
        for (int i = 0; i < recommendations.size(); i++) {
            JsonObject filmObj = recommendations.get(i).getAsJsonObject();
            recommendedTitles.add(filmObj.get("id").getAsString());
        }

        return recommendedTitles;
    }
}
