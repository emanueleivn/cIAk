import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

models = ['Logistic Regression', 'CatBoost', 'Random Forest']

# Metriche
accuracy = [0.7416, 0.7368, 0.7361]
precision = [0.68, 0.66, 0.69]
recall = [0.44, 0.46, 0.40]
f1_score = [0.54, 0.54, 0.50]

# Matrici di confusione
conf_matrices = {
    'Logistic Regression': np.array([[867, 102], [276, 218]]),
    'CatBoost': np.array([[851, 118], [267, 227]]),
    'Random Forest': np.array([[881, 88], [298, 196]])
}

# Grafico metriche
plt.figure(figsize=(12, 6))
x = np.arange(len(models))

bars1 = plt.bar(x - 0.3, accuracy, width=0.2, label='Accuracy', color='red')
bars2 = plt.bar(x - 0.1, precision, width=0.2, label='Precision', color='blue')
bars3 = plt.bar(x + 0.1, recall, width=0.2, label='Recall', color='green')
bars4 = plt.bar(x + 0.3, f1_score, width=0.2, label='F1-score', color='gold')

# Aggiunta dei valori sopra le barre
for bars in [bars1, bars2, bars3, bars4]:
    for bar in bars:
        plt.text(bar.get_x() + bar.get_width() / 2, bar.get_height(),
                 f'{bar.get_height():.2f}', ha='center', va='bottom', fontsize=10)

plt.xticks(x, models)
plt.xlabel('Modelli')
plt.ylabel('Valori')
plt.title('Confronto delle Metriche')
plt.legend()
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.show()

# Matrici di confusione
conf_labels = ['TN', 'FP', 'FN', 'TP']
plt.figure(figsize=(15, 5))
for i, (model, cm) in enumerate(conf_matrices.items(), 1):
    plt.subplot(1, 3, i)
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=['FP', 'TP'], yticklabels=['TN', 'FN'])
    plt.title(f'Matrice di Confusione - {model}')
    plt.xlabel('Predetto')
    plt.ylabel('Reale')

plt.tight_layout()
plt.show()

# Precision vs Recall
plt.figure(figsize=(8, 6))
plt.plot(recall, precision, 'o-', label='Precision vs Recall', color='black')
for i, model in enumerate(models):
    plt.text(recall[i], precision[i], model, fontsize=12, ha='right')

plt.xlabel('Recall')
plt.ylabel('Precision')
plt.title('Precision vs Recall per Modello')
plt.grid()
plt.legend()
plt.show()
