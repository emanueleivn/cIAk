package it.unisa.application.utilities;

import it.unisa.application.model.entity.Film;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class ReccomandationAdapter {
    private static final String RECOMMENDATION_URL = "http://localhost:5000/recommend";
    private static final String API_KEY = "chiaveAPI";
    private List<Film> filmsPrenotati;

    public ReccomandationAdapter(List<Film> filmsPrenotati) {
        this.filmsPrenotati = filmsPrenotati;
    }

    public List<String> getRecommendations() {
        List<String> recommendedTitles = new ArrayList<>();
        if (filmsPrenotati == null || filmsPrenotati.isEmpty()) {
            return recommendedTitles; // Nessun film prenotato => nessun consiglio
        }
        HttpURLConnection conn = null;
        try {
            JSONObject requestBody = new JSONObject();
            JSONArray filmPrenotatiArray = new JSONArray();
            for (Film f : filmsPrenotati) {
                JSONObject filmJson = new JSONObject();
                filmJson.put("id", f.getId());
                filmJson.put("titolo", f.getTitolo() != null ? f.getTitolo() : "");
                filmJson.put("genere", f.getGenere() != null ? f.getGenere() : "");
                filmJson.put("regista", f.getRegista() != null ? f.getRegista() : "");
                filmJson.put("cast", f.getCast() != null ? f.getCast() : "");
                filmJson.put("durata", f.getDurata());
                filmPrenotatiArray.put(filmJson);
            }
            requestBody.put("film_prenotati", filmPrenotatiArray);
            requestBody.put("top_n", 3);
            URL url = new URL(RECOMMENDATION_URL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            //Header
            conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);
            // Invio richiesta
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            // Lettura risposta
            int status = conn.getResponseCode();
            if (status == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    JSONArray jsonArray = new JSONArray(response.toString());
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject obj = jsonArray.getJSONObject(i);
                        String titolo = obj.optString("titolo", null);
                        if (titolo != null) {
                            recommendedTitles.add(titolo);
                        }
                    }
                }
            } else {
                // Debug errori di risposta
                System.err.println("ReccomandationAdapter: chiamata fallita con status code "
                        + status);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        return recommendedTitles;
    }
}
