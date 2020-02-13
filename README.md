# Cartograms: distorting geography to tell more with maps: exploration of China's one-child policy

There is a great geo-analytical technique for transforming a map so as to reshape borders and areas in proportion to some variable. For instance, a world map reshaped in proportion to country population would make countries with higher population appear bigger (think China and India) and countries with smaller population that otherwise on a regular map cover major land area appear smaller (think Russia).

There is an R package aptly named “cartogram” that can do this, and a great tutorial over here (https://www.r-graph-gallery.com/cartogram.html). But in general, this technique is ages old and there are many types of cartograms that can be created in various software packages. For instance, there are contiguous cartograms where borders stay connected, but the shape of a country gets stretched. There are also non-contiguous cartograms where the borders stay the same, but the size of the country changes, thus no longer “touching” its neighbors. And there are many algorithms, read the Wiki (https://en.wikipedia.org/wiki/Cartogram).

Here is a regular map, after removing Antarctica and changing map projection (https://en.wikipedia.org/wiki/List_of_map_projections) to Robinson, with colors indicating population in 2020:

![World map](https://raw.githubusercontent.com/evpu/Cartogram-WPP/master/world_2020.png)

And here is the same map, but reshaped in proportion to population in 2020:

![Cartogram based on population in 2020](https://raw.githubusercontent.com/evpu/Cartogram-WPP/master/cartogram_2020.png)

What if one were to reshape the borders in proportion not to population as of today, but population as forecasted for the end of the century, year 2100? Where can one get these forecasts from? They are available from the UN World Population Prospects (https://population.un.org/wpp/), or WPP for short, a database of world population, historical and forecasted, broken down by age and gender, with additional key population metrics, such as birth and mortality rates. The database is updated every couple of years to reflect the most recent data. Various forecasts for population growth (or decline!) are available based on different assumptions on fertility, mortality, and migration.

So, here is the map reshaped in proportion to population in 2100:

![Cartogram based on population in 2100](https://raw.githubusercontent.com/evpu/Cartogram-WPP/master/cartogram_2100_medium.png)

Notice: China has shrunk in size! Why could that be? There are two possible explanations. The obvious: China’s population must be smaller in 2100. Indeed, it is: from 1.44 billion in 2020 (according to WPP) to 1.06 billion in 2100. There are many demographical factors at play in this population decline, the effects of the one-child policy being the number one reason.

If we did not know that, another possible explanation for the size shrinkage might be that China’s population is not declining, but is simply not growing as fast as the rest of the world’s. After all, the cartogram reshapes the borders proportionally, taking into account population size in all countries.

Remember, the World Population Prospects database has variations of the population forecasts, given different assumptions on fertility, mortality, and migration. Is there any scenario where China’s population would actually increase? Yes, there are some. For example, under the “High” variant population of China in 2100 would be 1.58 billion.
So, here is the map reshaped in proportion to population in 2100, high variant:

![Cartogram based on population in 2100, high variant](https://raw.githubusercontent.com/evpu/Cartogram-WPP/master/cartogram_2100_high.png)

Now, while colors have changed, population increased across countries, and in relative terms China still appears smaller. Is there any scenario where China would increase or at least stay in its 2020 size? Not really. The world population in 2020 is 7.79 billion, China accounts for 1.44/7.79 = 18% of it. As of today, this is the highest proportion possible, by 2100 population of China as percent of the world is smaller under all WPP projection scenarios:

![ Population of China as Percent of the World](https://raw.githubusercontent.com/evpu/Cartogram-WPP/master/forecast_variants.png)

Granted, many things could change between 2020 and 2100, and WPP projections are revised regularly. So maybe China will see an increase in its cartogram size by 2100 after all.

Resources:

World Population Prospects: https://population.un.org/wpp/

Natural Earth shapefile: https://www.naturalearthdata.com
