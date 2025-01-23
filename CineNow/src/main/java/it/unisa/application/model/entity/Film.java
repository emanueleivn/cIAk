package it.unisa.application.model.entity;

public class Film {
    private int id;
    private String titolo;
    private String genere;
    private String classificazione;
    private int durata;
    private byte[] locandina;
    private String descrizione;
    private boolean isProiettato;
    private String regista;
    private String cast;

    public Film() {
    }

    public Film(int id) {
        this.id = id;
    }

    public Film(int id, String titolo, String genere, String classificazione, int durata, byte[] locandina, String descrizione, String regista, String cast, boolean isProiettato) {
        this.id = id;
        this.titolo = titolo;
        this.genere = genere;
        this.classificazione = classificazione;
        this.durata = durata;
        this.locandina = locandina;
        this.descrizione = descrizione;
        this.isProiettato = isProiettato;
        this.regista = regista;
        this.cast = cast;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitolo() {
        return titolo;
    }

    public void setTitolo(String titolo) {
        this.titolo = titolo;
    }

    public String getGenere() {
        return genere;
    }

    public void setGenere(String genere) {
        this.genere = genere;
    }

    public String getClassificazione() {
        return classificazione;
    }

    public void setClassificazione(String classificazione) {
        this.classificazione = classificazione;
    }

    public int getDurata() {
        return durata;
    }

    public void setDurata(int durata) {
        this.durata = durata;
    }

    public byte[] getLocandina() {
        return locandina;
    }

    public void setLocandina(byte[] locandina) {
        this.locandina = locandina;
    }

    public String getDescrizione() {
        return descrizione;
    }

    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    public boolean isProiettato() {
        return isProiettato;
    }

    public void setProiettato(boolean proiettato) {
        isProiettato = proiettato;
    }

    public String getRegista() {
        return regista;
    }

    public void setRegista(String regista) {
        this.regista = regista;
    }

    public String getCast() {
        return cast;
    }

    public void setCast(String cast) {
        this.cast = cast;
    }

    @Override
    public String toString() {
        return "Film{" +
                "id=" + id +
                ", titolo='" + titolo + '\'' +
                ", genere='" + genere + '\'' +
                ", classificazione='" + classificazione + '\'' +
                ", durata=" + durata +
                ", locandina='" + locandina + '\'' +
                ", descrizione='" + descrizione + '\'' +
                ", isProiettato=" + isProiettato +
                '}';
    }
}
