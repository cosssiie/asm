import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class FindSubstring {
    public static void main(String[] args) throws IOException {
        // Шлях до файлу
        String filePath = DataInput.getString("Шлях до файлу: ");

        // Підстрічка, яку потрібно знайти
        String substringToFind = DataInput.getString("Підстрічка: ");

        try {
            // Створення об'єкта BufferedReader для зчитування файлу
            BufferedReader reader = new BufferedReader(new FileReader(filePath));
            String line;
            int lineNumber = -1;
            int[][] results = new int[100][2]; // Масив для зберігання результатів

            // Зчитуємо рядки з файлу по одному
            while ((line = reader.readLine()) != null) {
                lineNumber++;

                // Порахуємо кількість входжень підстрічки на цій стрічці
                int count = countOccurrences(line, substringToFind);

                // Запишемо результат у масив
                results[lineNumber][0] = count;
                results[lineNumber][1] = lineNumber;
            }

            reader.close();

            // Сортуємо результати
            bubbleSort(results);

            // Виводимо відсортовані результати
            for (int i = 0; i < results.length; i++) {
                if (results[i][0] != 0) {
                    System.out.println(results[i][0] + " " + results[i][1]);
                }
            }
        } catch (IOException e) {
            System.err.println("Помилка при зчитуванні файлу: " + e.getMessage());
        }
    }

    // Метод для підрахунку кількості входжень підстрічки в стрічці
    public static int countOccurrences(String text, String substring) {
        int count = 0;
        int index = 0;
        while ((index = text.indexOf(substring, index)) != -1) {
            count++;
            index += substring.length();
        }
        return count;
    }

    // Метод для сортування результатів за кількістю входжень
    public static void bubbleSort(int[][] results) {
        int n = results.length;
        for (int i = 0; i < n - 1; i++) {
            for (int j = 0; j < n - i - 1; j++) {
                if (results[j][0] > results[j + 1][0]) {
                    int[] temp = results[j];
                    results[j] = results[j + 1];
                    results[j + 1] = temp;
                }
            }
        }
    }
}