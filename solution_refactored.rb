require 'Matrix'
require 'pp'
require 'pry'

class Vehicle
  attr_accessor :current_x
  attr_accessor :current_y
  attr_accessor :time_to_reach_destination
  attr_accessor :paid_run
  attr_accessor :runs
  #methods here

  def initialize
    self.runs = []
    self.paid_run = false
    self.current_x = 0
    self.current_y = 0
    self.time_to_reach_destination = nil
  end


  def take_a_ride
    min_distance_ = $T+1
    min_distance_ride_ = nil
    min_distance_ride_index_ = nil
    min_distance_ride_time_to_reach_destination = nil


    $rides.each_with_index do|ride_, index|
      #distanza per raggiungere la corsa
      distance_ = SolutionClass.compute_distance( ride_.start_x, ride_.start_x, self.current_x, self.current_y)

      time_to_accomplish_ = $current_T + distance_ + ride_.distance

      # eligibilità
      # distance to reach start < start_time
      # debugger
      if !ride_.assigned? && (time_to_accomplish_ <= ride_.latest_finish) && ($current_T + distance_ >= ride_.earlier_start)
        #la prendo in carico
        if time_to_accomplish_ < min_distance_
          min_distance_ride_ = ride_
          min_distance_ride_index_ = index
          min_distance_ride_time_to_reach_destination =  time_to_accomplish_
          min_distance_ = time_to_accomplish_
        end
        # return
      end
    end


    #assignment
    unless min_distance_ride_.nil?
      puts "Run #{min_distance_ride_index_} taken"
      self.time_to_reach_destination = min_distance_ride_time_to_reach_destination
      self.current_x= min_distance_ride_.destination_x
      self.current_y= min_distance_ride_.destination_y
      self.paid_run = true
      self.runs.push(min_distance_ride_index_)
      min_distance_ride_.assign!
    end
  end

  def free_current_vehicle
    self.time_to_reach_destination -= 1
    # debugger if $current_T == 50
    if self.time_to_reach_destination == 0
      puts "Run completed"
      self.paid_run = false
    end

  end

end



class Ride
  attr_accessor :start_x
  attr_accessor :start_y
  attr_accessor :destination_x
  attr_accessor :destination_y
  attr_accessor :earlier_start  #verificare con T residuo
  attr_accessor :latest_finish
  attr_accessor :distance
  attr_accessor :assigned #la corsa è stata presa in carico

  #methods here

  def initialize start_x, start_y, destination_x, destination_y, earlier_start, latest_finish
    #retrieved
    self.start_x = start_x
    self.start_y = start_y
    self.destination_x = destination_x
    self.destination_y = destination_y
    self.earlier_start = earlier_start
    self.latest_finish =latest_finish
    #computed
    self.assigned = false
    self.distance = SolutionClass.compute_distance(destination_x, start_x, destination_y, start_y)
  end

  def assigned?
    return self.assigned
  end

  def assign!
    self.assigned = true
  end
end




class SolutionClass

  def run_algorithm
    setup_environment
    import_values

    $T = $T.to_i

    while $current_T < $T
      puts "step #{$current_T} of #{$T}"
      $vehicles.each do |vehicle|
        if (vehicle.paid_run && (!vehicle.time_to_reach_destination.nil? &&  vehicle.time_to_reach_destination > 1))
          vehicle.time_to_reach_destination -= 1
          next
        end
        vehicle.free_current_vehicle if vehicle.paid_run
        vehicle.take_a_ride unless vehicle.paid_run
        # debugger
      end

      $current_T += 1
      # debugger if $current_T>=50
    end

    #  get_M_and_T_count_since_an_index 0,1,0,3

    #binding.pry
  end


  def setup_environment
    $first_line= true
    # $matrix = Matrix[]
    # $matrix_to_a
    $vehicles = []
    $current_T = 0
    $rides=[]
  end

  def import_values
    index_ = 0
    # File.open("b_should_be_easy.in", "r") do |f|
      #   File.open("c_no_hurry.in", "r") do |f|
      File.open("d_metropolis.in", "r") do |f|
      f.each_line do |line_|  #cambiare in each with index
        if $first_line
          get_control_values line_
          setup_fleet
        else
          l_ = line_.strip.split(' ').map(&:to_i)
          # distance_ = (l_[2] - l_[0]).abs + (l_[3] - l_[1]).abs
          # $matrix = Matrix.rows($matrix.to_a << (l_ << distance_ << false)) # false significa che la corsa non è stata presa in carico
          # index_+=1
          $rides.push(Ride.new(*l_))

        end
        # puts line_
      end
      # $matrix_to_a = $matrix.to_a
      # $matrix


    end

    # puts 'control' + $R + ' ' + $C + ' ' + $F + ' ' + $N + ' ' + $B + ' ' + $T + ' '
    puts "#{$R} rows, #{$C} columns, #{$F} vehicles, #{$N} rides, #{$B} bonus and #{$T} steps"
  end




  def get_control_values first_line_
    array_of_control_values_ = first_line_.strip.split(' ')
    $R=array_of_control_values_[0]
    $C=array_of_control_values_[1]
    $F=array_of_control_values_[2]
    $N=array_of_control_values_[3]
    $B=array_of_control_values_[4]
    $T=array_of_control_values_[5]

    $first_line= false
  end


  def setup_fleet
    #1 creo la flotta

    #:current_x, :current_y, :time_to_reach_destination, :destination_x, :destination_y, :paid_run
    $F.to_i.times do

      v_ = Vehicle.new
      v_.current_x =  0
      v_.current_y = 0
      v_.time_to_reach_destination= nil
      v_.paid_run =  false
      $vehicles << v_
    end

  end

  def self.compute_distance x0,y0, x1,y1
    (x1 - x0).abs + (y1 - y0).abs
  end






end

s_ = SolutionClass.new
s_.run_algorithm

File.open('rubberduck_met.out', 'w') do |f|
  $vehicles.each do |v_|
    f.write("#{v_.runs.count} #{v_.runs.join(' ')}\n")
  end
end
