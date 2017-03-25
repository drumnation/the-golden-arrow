begin
  require 'watir'
rescue Gem::LoadError
  `gem install watir`
  `gem install chromedriver-helper`
end

# initialize chrome browser driver
$browser = Watir::Browser.new :chrome

def great_artists_pair(lesson_name, class_id, lesson_filename)
  $lesson_name = lesson_name
  $class_id = class_id
  $lesson_filename = lesson_filename

  # scrape usernames to an array
  def scrape_students
    student_lesson_forks_url = "https://github.com/learn-co-students/#{$lesson_name}-#{$class_id}/network/members"
    $browser.goto(student_lesson_forks_url)
    divs = $browser.divs(class: 'repo')
    divs.collect do |div|
      div.text.split(" / ")[0]
    end
  end

  # create file url hash {:student => solution_file_url}
  def lesson_file_urls_hash(scrape_students)
    scrape_students.each_with_object({}) do |student, solution_urls|
      solution_urls[student] = "https://raw.githubusercontent.com/#{student}/#{$lesson_name}-#{$class_id}/master/#{$lesson_filename}"
    end
  end

  # set has to variable
  urls_hash = lesson_file_urls_hash(scrape_students)
  
  # scrape answers to array - if empty or default shovel to @lonely_students
  def great_artists_scrape(urls_hash)
    @answer_array = []
    @lonely_students = []
    @empty_answer = ""

    # iterate through list of student lesson urls and name
    urls_hash.each do |name, file_url|

      def output_to_array(name, file_url)

        # go to student lesson file url
        $browser.goto(file_url) 
        
        # save the default empty answer state from learn-co-students
        if name == "learn-co-students" 
          @empty_answer = $browser.text
        end

        # if answer is blank or is the default state shove name to @lonely_students
        if $browser.text == "" || $browser.text == @empty_answer
          @lonely_students << name
        end

      end
      output_to_array(name, file_url)
    end

    # puts all the students who haven't completed X lab
    def lonely_students_need_partners
      @lonely_students.each_with_index do |student, i|
        if i >= 1 
          puts "#{i}. #{student} needs a partner"
          puts " "
        end
      end
    end
    lonely_students_need_partners 
  end
  great_artists_scrape(urls_hash)
end

def golden_arrow_cli # command line interface and menus

  def greetings
    print "\e[8;15;46t" # resize terminal window

    welcome = <<~HEREDOC
     ------------------------------------------
    |     GREETINGs FLATIRON DATA EXPLORER!    |
    |----------------------------------------- |
    |                                          |
    |      \\\\\\\\\\\_____________________\\"-._     |
    |      /////~~~~~~~~~~~~~~~~~~~~~/.-'      |
    |                                          |
    |                                          |
    |------------------------------------------|
    |   You've retrieved the Golden Arrow!     |
    |------------------------------------------|
    | Use it to find out who hasn't started a  |
    | lab so you can ask them to pair with you.|
     ------------------------------------------
    HEREDOC
    # Look how silly the fix for that arrow is...
    # Had to escape all the backslashes in the design
    
    puts welcome 
    sleep(3)
    puts `clear`
    menu
  end


  def menu
    puts `clear`

    class_menu = <<~HEREDOC
    ---------------------------------------------
    |          SELECT A FLATIRON CLASS          |
    ---------------------------------------------
    |                                           |
    |  1. Magical Bears Eating Pears |   11-16  |  
    |  2. Cuddly Pair Bears          |   02-17  |  
    |  3. Eyes on the Man-Pair-Pig   | 03-13-17 |
    |                                           |
    ---------------------------------------------
    |             Press Q to Quit               |
    ---------------------------------------------
    HEREDOC

    puts class_menu

    case gets.strip.upcase

    when "1"
      class_id = "1116"
      get_lesson_name_path_run(class_id)
    when "2"
      class_id = "0217"
      get_lesson_name_path_run(class_id)
    when "3"
      class_id = "031317"
      get_lesson_name_path_run(class_id)
    when "Q"
      return
    else
      puts `clear`

      invalid_input = <<~HEREDOC
      ---------------------------------------------
      |          SELECT A FLATIRON CLASS          |
      ---------------------------------------------
      |                                           |
      |  1. Magical Bears Eating Pears |   11-16  |  
      |  2. Cuddly Pair Bears          |   02-17  |  
      |  3. Eyes on the Man-Pair-Pig   | 03-13-17 |
      |                                           |
      ---------------------------------------------
      |             Press Q to Quit               |
      ---------------------------------------------
      HEREDOC

      puts invalid_input

    end
  end

  def get_lesson_name_path_run(class_id)
    print "\e[8;25;46t"
    puts `clear`
    puts <<~HEREDOC

    > Copy pasta the lesson name as it appears 
      on GitHub without -classname.

      ex. ruby-objects-has-many-lab-web

    HEREDOC
    
    lesson_name = gets.strip.downcase
    
    puts <<~HEREDOC

    > Enter the relative path to the solution 
      file on GitHub.
    
      ex. lib/song.rb

    HEREDOC

    lesson_filename = gets.strip.downcase

    # STATUS MESSAGES

    print "\e[8;40;48t"
    puts `clear`
    puts "@@> Generating list of very lonely students. <@@"
    puts "/"
    sleep (1)
    puts "*"
    sleep(1)
    puts "\\"
    puts "    >>>> | RELEASING GOLDEN ARROW | <<<<<"
    puts " "
    puts " "
    sleep(1)
    puts "                LESSON TITLE"
    puts "           #{lesson_name}"
    puts " "
    
    # RUN THE PROGRAM

    great_artists_pair(lesson_name, class_id, lesson_filename)
    
    puts " "
    puts "...THE GOLDEN ARROW - MATCH LISTING COMPLETE..."
    puts " "
  end
  greetings
end

golden_arrow_cli
