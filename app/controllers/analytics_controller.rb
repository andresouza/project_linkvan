class AnalyticsController < ApplicationController
  def new
  end

  def create
  end

  def show
    @user = User.find(params[:id])
    if (@user.admin)
      @mapData = gridSort(Analytic.all, 0.001, 49.279869, -123.099512)

      @raw_service_chart_data = Analytic.group(:service).count
      @service_chart_data = []
        .push(@raw_service_chart_data['Shelter'])
        .push(@raw_service_chart_data['Food'])
        .push(@raw_service_chart_data['Medical'])
        .push(@raw_service_chart_data['Hygiene'])
        .push(@raw_service_chart_data['Technology'])
        .push(@raw_service_chart_data['Legal'])
        .push(@raw_service_chart_data['Learning'])
        .push(@raw_service_chart_data['Crisis Lines'])

      @time_chart_data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      @service_time_chart_data = {
        "Shelter" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Food" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Medical" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Hygiene" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Technology" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Legal" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Learning" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        "Crisis Lines" => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      }
      Analytic.order(:time).each do |data|
        puts data.service
        case data.service
        when "Shelter", "Food", "Medical", "Hygiene", "Technology", "Legal", "Learning", "Crisis Lines"
            time = data.time.localtime
            secs = time.seconds_since_midnight()
            hour = (secs / 3600).floor
            @time_chart_data[hour] += 1
            @service_time_chart_data[data.service][hour] += 1
        end
      end
    end
  end

  def destroy
  end

  private

  MapColors = {
    0 => "#00CC99",
    10 => "#009900",
    25 => "#FFFF00",
    50 => "#FF6600",
    100 => "#FF3300"
  }

  def gridSort(data, gridSize, centerLat, centerLng)
    remFactor = 10000000
    size = gridSize * remFactor
    cLat = centerLat * remFactor
    cLng = centerLng * remFactor
    blocks = Hash.new
    data.each do |it|
      if (it.lat != 0 && it.long != 0)
        itLat = it.lat * remFactor
        latOffset = ((itLat - cLat) / size).floor
        itLng = it.long * remFactor
        lngOffset = ((itLng - cLng) / size).floor
        if (blocks[latOffset] == nil)
          newBlock = Hash.new
          newBlock[lngOffset] = 1
          blocks[latOffset] = newBlock
        else
          if (blocks[latOffset][lngOffset] == nil)
            blocks[latOffset][lngOffset] = 1
          else
            blocks[latOffset][lngOffset] += 1
          end
        end
      end
    end
    rectAry = Array.new
    blocks.each do |latOffset, lngs|
      lngs.each do |lngOffset, count|
        lat = (latOffset * gridSize) + centerLat
        lng = (lngOffset * gridSize) + centerLng
        rect = {
          "north" => lat + gridSize,
          "south" => lat,
          "east" => lng + gridSize,
          "west" => lng,
          "count" => count,
          "fillColor" => getGridColor(count)
        }
        rectAry.push(rect)
      end
    end
    return rectAry
  end

  def getGridColor(count)
    sortedKeys = MapColors.keys
    sortedKeys.each_index do |i|
      if (count < sortedKeys[i])
        return MapColors[sortedKeys[i]]
      end
    end
    return MapColors[sortedKeys[sortedKeys.length - 1]]
  end
end
