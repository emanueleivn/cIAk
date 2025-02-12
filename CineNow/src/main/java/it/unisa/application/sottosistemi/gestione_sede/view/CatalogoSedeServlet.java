package it.unisa.application.sottosistemi.gestione_sede.view;

import it.unisa.application.model.entity.Cliente;
import it.unisa.application.model.entity.Film;
import it.unisa.application.model.entity.Prenotazione;
import it.unisa.application.model.entity.Sede;
import it.unisa.application.sottosistemi.gestione_prenotazione.service.StoricoOrdiniService;
import it.unisa.application.sottosistemi.gestione_sede.service.ProgrammazioneSedeService;
import it.unisa.application.utilities.ReccomandationAdapter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/Catalogo")
public class CatalogoSedeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String sede = req.getParameter("sede");
        if (sede == null || sede.isBlank()) {
            req.setAttribute("errorMessage", "Errore caricamento catalogo: sede non specificata");
            req.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(req, resp);
            return;
        }
        Sede sedeObject = new Sede();
        List<Film> catalogo;
        sedeObject.setNome(sede);
        ProgrammazioneSedeService service = new ProgrammazioneSedeService();
        switch (sede) {
            case "Mercogliano":
                sedeObject.setId(1);
                catalogo = service.getCatalogoSede(sedeObject);
                req.setAttribute("sede", "Mercogliano");
                req.setAttribute("sedeId", sedeObject.getId());
                break;
            case "Laquila":
                sedeObject.setId(2);
                catalogo = service.getCatalogoSede(sedeObject);
                req.setAttribute("sede", "L'Aquila");
                req.setAttribute("sedeId", sedeObject.getId());
                break;
            default:
                req.setAttribute("errorMessage", "Errore caricamento catalogo");
                req.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(req, resp);
                return;
        }
        //Controllo preferenze utente
        StoricoOrdiniService storicoOrdiniService = new StoricoOrdiniService();
        Cliente cliente = (Cliente)req.getSession().getAttribute("cliente");
        if(cliente!=null){
            List<Prenotazione> prenotazioni=storicoOrdiniService.storicoOrdini(cliente);
            if(prenotazioni!=null && !prenotazioni.isEmpty()){
                List<Film> prenotazioniFilm = new ArrayList<>();
                for (Prenotazione prenotazione : prenotazioni) {
                    prenotazioniFilm.add(prenotazione.getProiezione().getFilmProiezione());
                }
                ReccomandationAdapter adapter = new ReccomandationAdapter(prenotazioniFilm);
                List<String> consigliati = adapter.getRecommendations();
                req.setAttribute("consigliati", consigliati);
            }
        }
        if (catalogo != null) {
            List<String> consigliati = (List<String>) req.getAttribute("consigliati");
            if(consigliati != null && !consigliati.isEmpty()) {
                catalogo.sort((film1, film2) -> {
                    boolean f1Consigliato = consigliati.contains(film1.getTitolo());
                    boolean f2Consigliato = consigliati.contains(film2.getTitolo());
                    if (f1Consigliato && !f2Consigliato) {
                        return -1;
                    }
                    if (f2Consigliato && !f1Consigliato) {
                        return 1;
                    }
                    return 0;
                });
            }
            req.setAttribute("catalogo", catalogo);
            req.getRequestDispatcher("/WEB-INF/jsp/catalogoSede.jsp").forward(req, resp);
        } else {
            req.setAttribute("errorMessage", "Errore caricamento. Catalogo vuoto");
            req.getRequestDispatcher("/WEB-INF/jsp/error.jsp").forward(req, resp);
        }
    }
}
