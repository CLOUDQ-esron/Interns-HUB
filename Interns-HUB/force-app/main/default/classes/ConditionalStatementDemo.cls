public class ConditionalStatementDemo {

    public static String evaluateConditions(Integer number, String category) {
        String result = '';

        // Basic if statement
        if (number > 100) {
            result += 'Number is greater than 100. ';
        }

        // if-else if-else
        if (number == 0) {
            result += 'Number is zero. ';
        } else if (number > 0 && number <= 100) {
            result += 'Number is between 1 and 100. ';
        } else {
            result += 'Number is negative or above 100. ';
        }

        // Ternary operator
        String evenOrOdd = (number % 2 == 0) ? 'Even' : 'Odd';
        result += 'It is an ' + evenOrOdd + ' number. ';

        // switch statement (Apex supports switch from v53.0 API onward)
        switch on category {
            when 'A' {
                result += 'Category is A. ';
            }
            when 'B' {
                result += 'Category is B. ';
            }
            when 'C' {
                result += 'Category is C. ';
            }
            when else {
                result += 'Unknown category. ';
            }
        }

        // Nested if
        if (number > 0) {
            if (number < 50) {
                result += 'Number is a small positive number. ';
            } else {
                result += 'Number is a large positive number. ';
            }
        }

        // Compound conditions with OR
        if (number < 0 || category == 'Z') {
            result += 'Either the number is negative or category is Z. ';
        }

        return result;
    }
}
