import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

int SHE = 0;
int HE = 1;

String queries[][] = { {"articles", "date", "copy"}, 
                       {"exhibitions", "aic_start_date", "description"},
                       {"events", "start_date", "description"} };

int year = 2010;
int month = 1;

List<Coordinate> points;
int sheTotal = 0;
int heTotal = 0;

// Class to store x,y coordinates more easily
class Coordinate {
  float x, y;

  Coordinate (float px, float py) {
    x = px;
    y = py;
  }
}

void setup() {
  size(1024, 576);
  frameRate(4);

  PFont f = createFont("RobotoMono-Regular.ttf", 32);
  textFont(f);

  points = new ArrayList<Coordinate>();
}

// This method runs once for each month's of data that is displayed
void draw() {
  if ((year < year() && month <= 12) || (year == year() && month <= month())) {
    background(255);

    fill(#ff0000);
    textAlign(CENTER);
    text("she", width*.35, 40);
    text("he", width*.65, 40);

    stroke(0);
    line(width/2, 20, width/2, height-20 );

    drawAllPoints();

    if (year == year() && month == month()) {
      fill(#ff0000);
      textAlign(RIGHT);
      text("2010–" + (month() == 1 ? 12 : month()-1) + "/" + (month() == 1 ? year()-1 : year()), width-20, 40);

      textAlign(RIGHT);
      text(sheTotal, width/2-20, 40);

      textAlign(LEFT);
      text(heTotal, width/2+20, 40);
    }
    else {
      fill(#ff0000);
      textAlign(RIGHT);
      text(month + "/" + year, width-20, 40);

      int she = 0;
      int he = 0;

      for (int q = 0; q < queries.length; q++) {
        // For each query type, get all text content for a given month: >= the first of the month and < the first
        // of the next month.
        JSONObject json = loadJSONObject("https://aggregator-data.artic.edu/api/v1/" + queries[q][0] + "/search"
          + "?query[range][" + queries[q][1]+ "][gte]=" + year + "-" + nf(month, 2)+ "-01"
          + "&query[range][" + queries[q][1]+ "][lt]=" + (month == 12 ? year+1 : year) + "-" + (month == 12 ? "01" : nf(month+1, 2)) + "-01"
          + "&query[range][" + queries[q][1]+ "][format]=yyyy-MM-dd"
          + "&fields=" + queries[q][2]
          + "&limit=120");

        JSONArray data = json.getJSONArray("data");

        // Loop through all the returned records and count he/she pronouns
        for (int i = 0; i < data.size(); i++) {
          if (!data.getJSONObject(i).isNull(queries[q][2])) {
            String copy = data.getJSONObject(i).getString(queries[q][2]);

            String[] strings = copy.toLowerCase().split("[ ,\\.']");

            for (String str : strings) {
              if (str.matches("her[s]?")) {
                she++;
              }
              if (str.equals("she")) {
                she++;
              }
              if (str.equals("herself")) {
                she++;
              }
              if (str.equals("him")) {
                he++;
              }
              if (str.equals("his")) {
                he++;
              }
              if (str.equals("he")) {
                he++;
              }
              if (str.equals("himself")) {
                he++;
              }
            }
          }
        }
      }

      // After ruinning all the queries, display the new points
      for (int i = 0; i < she; i++) {
        addPoint(SHE, she);
      }
      for (int i = 0; i < he; i++) {
        addPoint(HE, he);
      }

      // And show the monthly totals
      textAlign(RIGHT);
      text(she, width/2-20, 40);
      sheTotal += she;

      textAlign(LEFT);
      text(he, width/2+20, 40);
      heTotal += he;

      // Prepare for the next month to display
      month++;
      if (month == 13) {
        month = 1;
        year++;
        println();
      }
    }

    // When exporting to a movie, uncomment this to generate frames
    //saveFrame("frames/shehe-######.png");
  }
}

void addPoint(int shehe, int total) {
  float x = random(10+(shehe == SHE ? 0 : width/2), (width/2)+(shehe == SHE ? 0 : width/2)-20);
  float y = random(60, height-20);

  points.add(new Coordinate(x, y));

  noStroke();
  fill(255, 0, 0);
  square(x, y, 10);
}

void drawAllPoints() {
  for (int i = 0; i < points.size(); i++) {
    noStroke();
    fill(200, 50);

    Coordinate c = points.get(i);
    square(c.x, c.y, 10);
  }
}
