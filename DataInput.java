import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public final class DataInput {

    public static Double getDouble(String message) {
        System.out.println(message);
        Double value = null;
        try {
            value = Double.valueOf(getString(""));
        } catch (NumberFormatException e) {
            System.out.println("Введено неправильне значння. Спробуйте ще раз");
            value = getDouble(message); 
        } catch (IOException e) {
            e.printStackTrace();
        }
        return value;
    }


    public static Long getLong(String message)  {
        System.out.println(message);
        String s = "";
        try {
            s = getString("");
        } catch (IOException e) {
            e.printStackTrace();
        }
        Long value = Long.valueOf(s);
        return value;
    }

    public static char getChar(String message) throws IOException {
        System.out.println(message);
        String s = getString(" ");
        return s.charAt(0);
    }

    public static Integer getInt(String message) {
        System.out.println(message);
        String s = "";
        try {
            s = getString("");
        } catch (IOException e) {
            e.printStackTrace();
        }
        Integer value = Integer.valueOf(s);
        return value;
    }

    public static String getString(String string) throws IOException {
        System.out.println(string);
        InputStreamReader isr = new InputStreamReader(System.in);
        BufferedReader br = new BufferedReader(isr);
        String s = br.readLine();
        return s;
    }


}
