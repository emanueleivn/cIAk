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

    // URL del servizio Flask (modificalo in base alla tua configurazione)
    private static final String RECOMMENDATION_URL = "http://localhost:5000/recommend";

    // API Key per l’autenticazione (se la tieni fissa o la leggi da config)
    private static final String API_KEY = "chiaveAPI";

    private List<Film> filmsPrenotati;

    /**
     * Costruttore: riceve la lista di Film prenotati dall'utente
     */
    public ReccomandationAdapter(List<Film> filmsPrenotati) {
        this.filmsPrenotati = filmsPrenotati;
    }

    /**
     * Esegue la chiamata al servizio Python per ottenere i consigli.
     * @return lista di titoli consigliati
     */
    public List<String> getRecommendations() {
        List<String> recommendedTitles = new ArrayList<>();

        if (filmsPrenotati == null || filmsPrenotati.isEmpty()) {
            return recommendedTitles; // Nessun film prenotato => nessun consiglio
        }

        HttpURLConnection conn = null;
        try {
            // 1) Costruzione dell'oggetto JSON da inviare
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

            // Opzionale: se vuoi limitare il numero di consigli da ricevere:
            requestBody.put("top_n", 3);

            // 2) Apertura connessione HTTP
            URL url = new URL(RECOMMENDATION_URL);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");

            // Header per l’autorizzazione e il tipo di contenuto
            conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

            // Permette di inviare dati in POST
            conn.setDoOutput(true);

            // 3) Invio del body JSON
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = requestBody.toString().getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            // 4) Lettura della risposta
            int status = conn.getResponseCode();
            if (status == 200) {
                // Se 200, allora abbiamo JSON con i film consigliati
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }

                    // Esempio di formattazione della risposta:
                    // [
                    //   {
                    //     "id": ...,
                    //     "titolo": "...",
                    //     "genere": "...",
                    //     "cast": "...",
                    //     "regista": "...",
                    //     "durata": ...,
                    //     "similarita": ...,
                    //     "probabilita_consigliato": ...,
                    //     "probabilita_normalizzata": ...,
                    //     "similarita_normalizzata": ...,
                    //     "punteggio_combinato": ...
                    //   },
                    //   { ... },
                    //   ...
                    // ]
                    JSONArray jsonArray = new JSONArray(response.toString());

                    // Dal JSON estraiamo (ad esempio) i titoli consigliati
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject obj = jsonArray.getJSONObject(i);
                        String titolo = obj.optString("titolo", null);
                        if (titolo != null) {
                            recommendedTitles.add(titolo);
                        }
                    }
                }
            } else {
                // Gestione di eventuali errori di risposta (es. 401, 500, ecc.)
                System.err.println(
                        "ReccomandationAdapter: chiamata fallita con status code " + status
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        System.out.println(recommendedTitles);
        return recommendedTitles;
    }

}
