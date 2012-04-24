class RootController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index, :auth, :failure]
	
	def translate(str)
		str = I18n.translate(str).to_s
		str.match(/missing/) ? "" : str
	end
	
	def days_in_month(year, month)
		(Date.new(year, 12, 31) << (12-month)).day
	end
	
	def workdays_in_month(first, last)
		month = first.month
		year = first.year
		workdays = 0
		for i in first.day..last.day
			date = Date.new(year, month, i)
			wday = date.wday
			if wday > 0 && wday < 6
				#if !Holiday.check("#{year}-#{toXX(month)}-#{toXX(i)}")
					workdays += 1
				#end
			else
				if wday == 6
					workdays -= Holiday.checkBetween("#{year}-#{toXX(month)}-#{toXX(i-5)}", "#{year}-#{toXX(month)}-#{toXX(i-1)}")
				end
			end
		end
		workdays
	end
	
	def toXX(int)
		int = "0"+int.to_s if int < 10
		int.to_s
	end

	def toHours(int)
		toXX(int) + ":00:00"
	end
	
	def toHHMMSS(sec)
		
		neg = ""
		if sec<0
			sec = (-sec)
			neg = "-"
		end
		
		h = (sec/3600).to_i
		sec -= h*3600
		
		m = (sec/60).to_i
		sec -= m*60
		
		neg+[toXX(h), toXX(m), toXX(sec.to_i)].join(":")
	end

	def br(str)
		"\n"+str
	end
	
	def ln(str)
		str+"\n"
	end
	
	def lt(str, int=1)
		if int > 1
			lt("\t"+str, int-1)
		else
			"\t"+str
		end
	end

	def li(id, item)
		#href = locale.nil? ? "/root/"+id : "/root/"+id+"?locale="+locale
		"<li id='#{id}'><a href='#{"/root/#{id}"}'>#{item.to_s}</a></li>"
	end
	
	def ul(id, list) # return list (ul) with id='id' and elements (li) from Array 'list'
		ul = ln lt("<ul id='#{id}'>")
		list.each{ |e| ul += ln lt(e, 2) }
		ul += lt("</ul>")
		ul
	end

  def menu
	menu = ul("menu", [li("profile",t(:personal)), li("frequency",t(:frequency)), li("logoff",t(:logoff))])
	!Admin.is_admin?(user_id) ? menu : menu + br( ul("menu_admin", [li("edit",t(:edit)), li("parameters",t(:parameters)), li("setholiday",t(:setholiday))]) )
  end
  
  def remove_button(remove, date=nil, default=nil)
	if default.nil?
		"<a class='button' style='visibility: hidden;' href='#'>#{remove}</a>"
	else
		"<a class='button' href='/root/check?remove=1&key=#{default}&date=#{date}&rectify=1'>#{remove}</a>"
	end
  end
  
  def time_input(date, default=nil)
	html = ""
	save = t(:btn_save)
	remove = t(:btn_remove)
	tmp = "<input type='hidden' name='rectify' value='1' /><input type='hidden' name='list' value='1' /><input type='hidden' name='date' value='#{date}' />"
	if default.nil?
		html = ln( lt("<form id='nosubmit' action='/root/check' method='GET'>#{tmp}<p class='time'><input id='time' name='time' type='text' />#{remove_button(remove)}<input class='button' type='submit' value='#{save}'/></p></form>",2) )
	else
		html = ln( lt("<form id='nosubmit' name='ts_#{default}' action='/root/check' method='GET'><input type='hidden' name='key' value='#{default}' />#{tmp}<p class='time'><input id='time' name='time' type='text' value='#{default}' />#{remove_button(remove, date, default)}<input class='button' type='submit' value='#{save}'/></p></form>",2) )
	end
  end
  
  def find_user
	# Check db for uid
	session[:db_user] = User.employee(user_id)[0]
	!session[:db_user].blank?
  end
  
  def check_date_justified(str_date)
	just = Justification.where(:user_id => user_id, :date => str_date)
	session[:motive] = just[0].motive unless just[0].nil?
	return just.length > 0
  end
  
  class Employee < RootController
	attr_accessor :id
	attr_accessor :name
	attr_accessor :position_id
	attr_accessor :position
	attr_accessor :locale
	attr_accessor :workload
	attr_accessor :bank
	attr_accessor :bank_start
	attr_accessor :bank_end
	attr_accessor :bank_hours
	attr_accessor :bank_id
	attr_accessor :last_reset
	attr_accessor :next_reset
	attr_accessor :current_bank
	def initialize(db_user, loc)
		@user = db_user
		@locale = loc
	end
	def id
		@user["user_id"]
	end
	def name
		@user["user_name"]
	end
	def position_id
		@user["position_id"]
	end
	def position
		@user["position_desc_#{locale}"]
	end
	def workload
		toHours(@user["position_workload"])
	end
	def bank_hours
		floatToHours(@user["bank_hours"])
	end
	def bank
		bank_end
	end
	def bank_start(mon=Date.current.change(:day => 1))
		floatToHours(MonthBank.where("bankofhours_id = #{bank_id} AND DATE(month) = DATE('#{mon.to_s(:db)}')").first.start_hours)
	end
	def bank_end(mon=Date.current.change(:day => 1))
		m = MonthBank.where("bankofhours_id = #{bank_id} AND DATE(month) = DATE('#{mon.to_s(:db)}')").first
		if m.end_hours.nil?
			#floatToHours(@user["bank_hours"])
			nil
		else
			floatToHours(m.end_hours)
		end
	end
	def bank_id
		@user["bankofhours_id"]
	end
	def last_reset
		@user["last_reset"].to_s[0..9]
	end
	def next_reset
		@user["next_reset"].to_s[0..9]
	end
  end
  
  def logoff
	locale = ( session[:locale].blank? || session[:locale].match(/pt-BR/) ) ? "" : "?locale=#{session[:locale]}"
	reset_session
	redirect_to "/#{locale}"
  end
  
  def index
	if user_signed_in?
		@html = ln lt "<h1>#{translate(:today) + I18n.localize(Date.current, :format => :long)}</h1>"
		@html += ln lt "<h2>#{translate(:welcome) + user_name}!</h2>"
		if find_user
			session[:menu] = menu
			@menu = session[:menu]
		else
			@html += ln lt "<p class='spaceup flash'>#{user_id} - #{t(:msg_nouser)}</p>"
			#@html += ln lt "<form action='newuser' class='spaceup'>"
			#@html += ln lt "<input type='hidden' name='user_id' value='#{user_id}'/>", 2
			#@html += ln lt "<input type='hidden' name='user_name' value='#{user_name}'/>", 2
			#@html += ln lt "<input type='submit' class='button' value='#{t(:newuser)}'/>", 2
			#@html += ln lt "<a href='root/logoff' class='button'>#{t(:logoff)}</a>", 2
			#@html += ln lt "</form>"
		end
	else
		@style = " style='height: 94.5%;'"
		@html = lt "<p class='spaceup spaceleft'>#{t(:msg_sign)} <a class='link' href='/auth/google'>#{t(:btn_sign)}.</a></p>"
	end
  end
  
  def profile
	@header = translate(:header_profile)
	@menu = session[:menu]
	
	@id = "ID: "
	@name = translate(:profile_name)
	@position = translate(:profile_position)
	@workload = translate(:profile_workload)
	@bank_of_hours = translate(:profile_bank)
	@last_reset = translate(:profile_last_reset)
	@next_reset = translate(:profile_next_reset)
	session[:employee] = Employee.new(session[:db_user], session[:locale][0..1])
	@employee = session[:employee]
  end
  
  def frequency
	# USER INTERFACE VARIABLES
	@header = t(:header_frequency)
	@menu = session[:menu]
	@print = t(:print)
	@months = ""
	now = Date.current
	
	#end_date = Date.current
	#ini_date = end_date - 5.months # Should be the first month after the last reset
	session[:employee] = Employee.new(session[:db_user], session[:locale][0..1])
	ini_date = Date.parse(session[:employee].last_reset)
	end_date = ini_date + 5.months
	selected = params[:month].present? ? Date.parse(params[:month]) : now
	selected = selected.change(:day => 1)
	begin
		link = I18n.localize(ini_date, :format => :month_and_year)
		jump = ""
		current = ""
		
		if ini_date < end_date
			jump = "\n\t\t"
		end
		
		if ini_date.month == selected.month
			@date = ini_date
			current = " class='current'"
			link = "<span style='display:inline-block; background-color: #FFFFBB; width: 95%; line-height: 2.5em;'>"+link+"</span>"
		else
			link = "<a href='/root/frequency?month=#{ini_date}'>"+link+"</a>"
		end
		
		@months += "<li rel='"+ini_date.to_s+"'#{current}>#{link}</li>#{jump}"
		ini_date += 1.month
	end while ini_date <= end_date
	
	month(selected) # Run def month for proper rendering template on the view
	
	# Month balance
	@month = t(:month)
	## Expected hours
	@month_expected = t(:frequency_exp)
	if now.month == selected.month
		yesterday = now-1.day
		exp = workdays_in_month(selected, yesterday)*session[:employee].workload.to_i
		month = Check.month(user_id, selected.to_s(:db), yesterday.to_s(:db))
	else
		selected_end = selected+1.month-1.day
		exp = workdays_in_month(selected, selected_end)*session[:employee].workload.to_i
		month = Check.month(user_id, selected.to_s(:db), selected_end.to_s(:db))
	end
	@month_expected += toHours(exp)
	
	if selected <= now
		## Worked hours
		@hide_future_date = true
		date = nil
		d1 = nil
		count = 0
		worked = 0.0
		for i in 0..(month.length-1)
			time = (month[i]["date"]+" "+month[i]["time"]).to_time
			if date == month[i]["date"]
				if count%2 == 0
					d1 = time
				else
					worked += (time - d1)
				end
			else
				date = month[i]["date"]
				d1 = time
			end
			count += 1
		end
		#Check for justifications to add hours
		worked += Justification.count(user_id, selected.to_s(:db), (selected+1.month-1.day).to_s(:db))*session[:employee].workload.to_i*3600
		@month_worked = t(:frequency_count)+toHHMMSS(worked)
			
		## Summary of positive/negative hours
		@month_extra = t(:frequency_ecount)
		expected = exp*3600
		if worked < expected
			# Negative hours
			@mclass = "red bold"
			neg = true
			@mextra = toHHMMSS(expected-worked)
		else
			# Positive hours
			@mclass = "blue bold"
			@mextra = toHHMMSS(worked-expected)
		end
		
		# Bank of hours
		@current_bank = "#{t(:current_bank)}"
		@updated_month = session[:employee].bank_start(selected)
		if hoursToFloat(@updated_month) < 0
			@class_month = 'red'
		else
			if hoursToFloat(@updated_month) > 0
				@class_month = 'blue'
			end
		end
		
		@new_bank = "#{t(:new_bank)}"
		newtime = hoursToFloat(@mextra)
		if neg
			newtime = -(newtime)
			@mextra = "-#{@mextra}"
		end
		newtime += hoursToFloat(session[:employee].bank_start(selected))
		#@updated_week = session[:employee].bank_end(selected).nil? ? floatToHours(newtime) : session[:employee].bank_end(selected)
		if session[:employee].bank_end(selected).nil?
			@updated_week = floatToHours(newtime)
			if @updated_week != session[:employee].bank_hours
				up = Bank.find_by_bankofhours_id(session[:employee].bank_id)
				up.bank_hours = newtime
				up.save
				find_user
			end
		else
			@updated_week = session[:employee].bank_end(selected)
		end
		if hoursToFloat(@updated_week) < 0
			@class_week = 'red'
		else 
			if hoursToFloat(@updated_week) > 0
				@class_week = 'blue'
			end
		end
	end
	
	#  Week balance - only show it for current month
	if now.month == selected.month
		@week = t(:week)
		@show_week = true
		# Expected hours for the week so far
		exp = (now.wday-1)*(session[:employee].workload.to_i)
		@week_expected = t(:frequency_exp)+toHours(exp)
		
		# Worked hours for the week so far
		@week_worked = t(:frequency_count)
		worked = 0.0
		d1 = nil
		count = 0
		week = Check.month(user_id, (now-(now.wday-1).day).to_s(:db), (now-1.day).to_s(:db))
		week.each do |x|
			if count%2 == 0
				d1 = "#{x["date"]} #{x["time"]}".to_time
			else
				worked += "#{x["date"]} #{x["time"]}".to_time - d1
			end
			count += 1
		end
		worked += Justification.count(user_id, (now-(now.wday-1).day).to_s(:db), now.to_s(:db))*session[:employee].workload.to_i*3600
		@week_worked += toHHMMSS(worked)
		
		# Summary of positive/negative hours
		@week_extra = t(:frequency_ecount)
		expected = exp*3600
		if worked < expected
			# Negative hours
			@class = "red bold"
			@extra = "-"+toHHMMSS(expected-worked)
		else
			# Positive hours
			@class = "blue bold" if worked > expected
			@extra = toHHMMSS(worked-expected)
			
			# Warn when closing in on 12 positive hours
			if (expected+(9*3600))<worked # Have more than 9 positive hours
				#@warn12 = "<p class='spaceup red bold'>#{t(:alert_12hours)}</p>"
				@warn12 = "#{t(:alert_12hours)}"
			end
		end
	end
  end
  
  def month(sel)
	# Show calendar and options for the month
	now = Date.current
	@date = now
	@date = sel if !sel.blank?
	@date = Date.parse(params[:date]) if params[:date].present?
	
	# Connect to db to check if month is closed
	open = MonthBank.where("bankofhours_id = #{session[:employee].bank_id} AND DATE(month) = DATE('#{@date.to_s(:db)}')").first
	open = Admin.is_admin?(user_id) || open.nil? || open.end_hours.nil? # No entry for the month (future month) or month not closed yet
	
		# Holidays
		session['20121#nowork'] = [1]
		session['20122#nowork'] = [21]
		session['20123#nowork'] = []
		session['20124#nowork'] = [6,21]
		session['20125#nowork'] = [1]
		session['20126#nowork'] = [7]
		session['20127#nowork'] = []
		session['20128#nowork'] = [15]
		session['20129#nowork'] = [7]
		session['201210#nowork'] = [12]
		session['201211#nowork'] = [2,15]
		session['201212#nowork'] = [8,25]
	@html = ln("<ul id='month'#{" rel='closed'" unless open}>")
	for x in 0..6
		@html += "<li class='label bg_grey'>#{t('date.abbr_day_names')[x]}</li>"
	end
	for i in 1..days_in_month(@date.year, @date.month)
		weekday = Date.new(@date.year,@date.month,i).strftime('%u').to_i
		if i==1 && weekday != 7
			@html += ln("<li class='bg_grey'>&nbsp;</li>")
			for j in 2..weekday
				@html += ln("<li>&nbsp;</li>")
			end
		end
		@class = ""
		@class += " bg_grey" if (weekday == 6) || (weekday == 7)
		@class += " clear_left" if (weekday == 7)
		@class += " holiday" if (weekday == 7) || ( !session[@date.year.to_s+@date.month.to_s+'#nowork'].nil? && session[@date.year.to_s+@date.month.to_s+'#nowork'].find{ |item| item == i } == i )
		@class += " current" if (i == now.day && now.month == @date.month)
		
		if ((@date.month < now.month) || (@date.month == now.month && i <= now.day)) && open
			@html += br("<li rel='#{@date.change(:day => i).to_s}' class='day active#{@class}'><a href='/root/day?date=#{@date.change(:day => i).to_s}'>#{i.to_s}</a></li>")
		else
			@html += br("<li rel='#{@date.change(:day => i).to_s}' class='day#{@class}'>#{i.to_s}</li>")
		end
		
	end
	@html += ln("</ul>")
  end
  
  def day
	# Show options for day of month
	@menu = session[:menu]
	date = Date.parse(params[:date]) if params[:date].present?
	@html = ln(lt("<h2 class='spacedown'>#{l(date, :format => :long)}</h2>"))
	
	if check_date_justified(date)
		@html += ln(lt("<p>#{t(:justified_abscence)}#{session[:motive]}</p>"))
		return true
	end
	
	now = Date.current
	check = date == now ? true : false
	rectify = true if params[:closed].nil? || !params[:closed].match(/closed/)
	rectify = false if date > now
	
	@html += ln(lt("<article id='timestamps'>"))
	count = 0

	# Connect to db to retrieve checks for the day for the logged user
	session[:date] = Check.day(user_id, date.to_s)
	d1 = nil
	d2 = nil
	count = 0
	if !session[:date].blank?
		session[:date].each do |x| 
			db_date = (date.to_s+" "+x["time"]).to_time
			if count%2 == 0
				d1 = db_date
			else
				if d2.nil?
					d2 = db_date - d1
				else
					d2 += db_date - d1
				end
			end
			@html += ln(lt("<p>#{db_date.to_s(:db)[-8..-1]}</p>",2))
			count += 1
		end
	else
		if date < now
			justify = true
		end
	end
	
	# Show sum of intervals
	@html += ln(lt("<p id='total' class='spaceup'>#{t(:sum_hours)}<label>#{toHHMMSS(d2)}</label></p>",2)) if !d2.blank?
	
	# Show button to check again if and only if it's the current day
	@html += ln(lt("<a id='check' class='button' href='/root/check'>#{t(:btn_check)}</a>",2)) if check
	
	# Show button to rectify inputs if and only if the month wasn't closed by the user before
	@html += ln(lt("<a id='rectify' class='button' href='/root/rectify?date=#{date.to_s}'>#{t(:btn_rectify)}</a>",2)) if rectify
	
	# Show button to justify an absence
	@html += ln(lt("<a id='justify' class='button' href='/root/justify?date=#{date.to_s}'>#{t(:btn_justify)}</a>",2)) if justify
	
	# Show button to check again if and only if it's the current day
	@html += ln(lt("<a id='oncall' class='button' href='/root/oncall?date=#{date.to_s}'>#{t(:btn_oncall)}</a>",2))
	
	@html += ln(lt("<p id='alert'>#{t(:alert_timestamp)}</p>",2)) if (count%2 != 0) # && (date == now)
	
	@html += lt("</article>")
  end
  
  def checkin(time, date, key=nil)
  # Create a new timestamp
	time = Time.now.strftime("%H:%M:%S") if time.nil?
	date = Date.current.to_s if date.nil?
	timestamp = "#{date} #{time}"
	
#	session[:date] = Check.day(user_id, date.to_s)
#	count = 0
#	d2 = nil
#	session[:date].each do |x|
#		db_date = (x["date"]+" "+x["time"]).to_time
#		if count%2 == 0
#			d1 = db_date
#		else
#				if d2.nil?
#					d2 = db_date - d1
#				else
#					d2 += db_date - d1
#				end
#		end
#	end
#	before = d2/3600.0
	
	if key.nil?
		Check.insert(user_id, timestamp)
	else
		Check.update(user_id, date, time, key)
	end
	
#	session[:date] = Check.day(user_id, date.to_s)
#	count = 0
#	d2 = nil
#	session[:date].each do |x|
#		db_date = (x["date"]+" "+x["time"]).to_time
#		if count%2 == 0
#			d1 = db_date
#		else
#				if d2.nil?
#					d2 = db_date - d1
#				else
#					d2 += db_date - d1
#				end
#		end
#	end
#	after = d2/3600.0
#	puts "\n#{before}\n#{after}\n#{after - before}"
#	b = Bank.find_by_bankofhours_id(session[:employee].bank_id)
#	b.bank_hours = b.bank_hours.to_f - before + after
#	b.save

	return date
  end
  
  def check(time=nil, date=nil)
	# Mark a timestamp for the user
	date = params[:date] if date.nil?
	
	if params[:remove].present?
		if params[:key].present?
			Check.delete(user_id, Time.parse("#{date} #{params[:key]}").to_s(:db))
		end
	else
		time = params[:time] if time.nil?
		date = checkin(time, date, params[:key])
	end
	
	session[:date] = Check.day(user_id, date.to_s)
	
	if params[:rectify].present?
		redirect_to "/root/rectify?date=#{date}"
	else
		redirect_to "/root/day?date=#{date}"
	end
  end
  
  def rectify
	# Rectify incorrect timestamps
	@menu = session[:menu]
	date = params[:date]
	@html = ln(lt("<h2 class='spacedown'>#{l(Date.parse(date), :format => :long)}</h2>"))
	@html += ln(lt("<article id='timestamps'>"))
	
	if !session[:date].nil?
		session[:date].each do |x| 			
			@html += time_input(date, x["time"])
		end
	end
	
	@html += time_input(date)
	
	@html += lt("</article>")
  end
  
  def justify
	@menu = session[:menu]
	date = Date.parse(params[:date])
	@html = ln(lt("<h2 class='spacedown'>#{l(date, :format => :long)}</h2>"))
	@html += ln(lt("<form id='justify' action='/savejustification'>"))
	@html += ln(lt("<input type='hidden' name='date' value='#{params[:date]}' />",2))
	@html += ln(lt("<p><label>Motive:</label><textarea id='motive' name='motive'></textarea></p>",2))
	@html += ln(lt("<p><input class='button' type='submit' /></p>",2))
	@html += lt("</form>")
  end
  
  def oncall(hash=nil)
	# Set up on-call hours
	@menu = session[:menu]
	date = params[:date]
	save = t(:btn_save)
	remove = t(:btn_remove)
	
	@html = ln(lt("<h2 class='spacedown'>#{l(Date.parse(date), :format => :long)}</h2>"))
	@html += ln(lt("<article id='timestamps'>"))
	
	@html += ln lt("<span><input id='time' name='time' type='text' class='clear_left' /><a class='button' style='visibility: hidden;' href='#remove'>#{remove}</a><a class='button' href='#save'>#{save}</a></span>",2)
	
	@html += lt("</article>")
  end
  
  def edit_tag(str, edit, id)
  # Generate the proper tag for "def user_profile(emp, edit)" based on whether they should be editable or not
	edit ? "<input id='#{id}' name='#{id}' value='#{str}' />" : "<label id='#{id}'>#{str}</label>"
  end
  
  def select_tag(str, edit, id, emp)
	edit ? "<select id='#{id}' name='#{id}'>#{options("localized_positions", "position_id", "position_desc_#{session[:locale][0..1]}", emp.position_id)}</select>" : "<label>#{str}</label>"
  end
  
  def field(label, content)
  # Generate form fields for "user_profile(emp, edit)"
  ln lt "<p>#{label}#{content}</p>"
  end
  
  def options(table, value, text, selected)
	reg = ActiveRecord::Base.connection.select_all "select #{value}, #{text} from #{table}"
	options = "\n"
	reg.each do |x|
		if x[value].to_i == selected.to_i
			options += "<option selected value=#{x[value]}>#{x[text]}</option>"
		else
			options += "<option value=#{x[value]}>#{x[text]}</option>"
		end
		options += "\n"
	end
	options
  end
  
  def user_profile(emp, edituser, editbank)
  # Generate a user profile for "def edit"
	name = translate(:profile_name)
	position = translate(:profile_position)
	last_reset = translate(:profile_last_reset)
	next_reset = translate(:profile_next_reset)
	bank = translate(:current_bank)
	
	ln("<div id='user'>")+
	
	ln("<form id='profile' action='/saveuser'>")+
	ln(lt "<input type='hidden' name='e_user_id' value='#{emp.id}' />")+
	field("ID: ", edit_tag(emp.id, false, "e_id"))+
	field(name, edit_tag(emp.name, false, "e_name"))+
	ln(lt "<p>#{position}#{select_tag(emp.position, edituser, "e_position", emp)}</p>")+
	ln(lt !edituser ? "<a class='button' href='/root/edit?id=#{emp.id}&edituser=1'>#{t(:btn_edit)}</a>" : "<a class='button' href='/root/edit?id=#{emp.id}'>#{t(:btn_cancel)}</a><input class='button' type='submit' value='#{t(:btn_save)}'/>")+
	ln("</form>")+
	
	ln("<form id='bank' action='/savebank'>")+
	ln(lt "<input type='hidden' name='e_bank_id' value='#{emp.bank_id}' />")+
	field(bank, edit_tag(emp.bank_start, editbank, "e_bank"))+
	field(last_reset, edit_tag(emp.last_reset, editbank, "e_last_reset"))+
	field(next_reset, edit_tag(emp.next_reset, editbank, "e_next_reset"))+
	ln(lt !editbank ? "<a class='button' href='/root/edit?id=#{emp.id}&editbank=1'>#{t(:btn_edit)}</a>" : "<a class='button' href='/root/edit?id=#{emp.id}'>#{t(:btn_cancel)}</a><input class='button' type='submit' value='#{t(:btn_save)}'/>")+
	ln("</form>")+
	
	ln("</div>")
   end
  
  def edit
  # Edit employee
  # Reset Bank of Hours
	@menu = session[:menu]
	
	@header = t(:header_edit)
	
	#(id, name, position, workload, bank, last_reset, next_reset)
	@users = User.employee
	
	@id = params[:id]
	if @id.present?
		@users.each do |x|
			if x["user_id"] == @id
				@html = user_profile(Employee.new(x, session[:locale][0..1]), params[:edituser].present?, params[:editbank].present?)
				break
			end
		end
	end
  end
  
  def parameters # <<<<<<<<<<<<<<<<<<<<<<<<<< THIS
  # Set up global parameters for extra hours
	@menu = session[:menu]
	
	#Extra Hours Month Limit 30
	#Seg-Sab <= Month Limit 1.25
	#Seg-Sab > Month Limit 1.5
	#Seg-Sab 5AM > X > 22PM 1.5
	#Dom-Fer 2.0
	#On-Call 10% (Mon-Fri) - 15% (Sat-Sun-Hol)
	#On-Call (required to stay) 20% (Mon-Fri) - 30% (Sat-Sun-Hol)
	
  end
  
  def holiday_line(id, text, date, remove=false, edit=false)
	op_default = "<form name='holiday_edit#{date}' action='/root/setholiday' class='clear_left'><div>#{text}</div><div>#{l(Date.parse(date), :format => :long)}</div><input type='hidden' name='day' value='#{date}'><input type='submit' value=#{t(:btn_edit)}></form>"
	op_edit = "<form name='holiday_save#{date}' action='/editholiday' class='clear_left'><div><input name='desc' value='#{text}' /></div><div><input name='day' value='#{date}' /></div><input type='hidden' name='id' value='#{id}' /><input type='submit' value='#{t(:btn_save)}'></form>"
	op_remove = "<form name='holiday_remove#{date}' action='/removeholiday' class='clear_left'><div>#{text}</div><div>#{l(Date.parse(date), :format => :long)}</div><input type='hidden' name='day' value='#{date}'><input type='submit' value=#{t(:btn_remove)}></form>"
	lt ln( remove ? op_remove : (edit ? op_edit : op_default) ), 2
  end
  
  def setholiday
	  # Set up holidays manipulating proper table with CRUD operations
	  @menu = session[:menu]
	  @html = lt ln "<div id='holidays'>"
	  @html += lt ln("<div class='bold'>#{t(:holiday)}</div><div class='bold'>#{t(:cal_date)}</div>"), 2
	  Holiday.current.each do |x|
		if params[:day].present? && params[:day] == x["day"]
			@html += holiday_line(x["id"], x["desc"], x["day"], params[:addremove].present?, true)
		else
			@html += holiday_line(x["id"], x["desc"], x["day"], params[:addremove].present?)
		end
	  end
	  if params[:addremove].present?
		@html += lt ln( "<form style='display:inline;' name='holiday_add' action='/addholiday' class='clear_left'><div><input name='desc' /></div><div><input name='day' /></div><input type='submit' value=#{t(:btn_save)}></form><form style='display:inline; float:left;' action='/root/setholiday'><input type='submit' value='#{t(:btn_cancel)}' /></form>" ), 2
	  else
		@html += lt "<a class='link' href='/root/setholiday?addremove=true'>#{t(:addremove_holiday)}</a>"
	  end
	  @html += lt "</div>"
  end
  
  def editholiday
	Holiday.update(params[:id], params[:day], (params[:desc]))
	if params[:ajax].present?
		redirect_to root_setholiday_path
	else
		redirect_to root_path
	end
  end
  
  def auth
	session[:omniauth] = request.env['omniauth.auth']
	redirect_to root_path
  end
  
  def failure
	flash[:error] = t(eval(":msg_"+params[:message]))
	redirect_to root_path
  end
  
  def newuser
	user_id = params[:user_id]
	user_name = params[:user_name]
	if user_id.present? && user_name.present?
		u = User.new(:user_id => user_id, :user_name => user_name)
		#u.save
	end
	redirect_to root_path
  end
  
  def saveuser
	u = User.find_by_user_id(params[:e_user_id])
	u.position_id = params[:e_position]
	u.save
	redirect_to root_path
  end
  
  def savebank	
	b = Bank.find_by_bankofhours_id(params[:e_bank_id])
	b.last_reset = params[:e_last_reset]
	b.next_reset = params[:e_next_reset]
	b.save
	
	m = MonthBank.where("bankofhours_id = #{params[:e_bank_id]} AND DATE(month) = DATE('#{Date.current.change(:day => 1).to_s(:db)}')").first
	m.start_hours = hoursToFloat(params[:e_bank])
	m.save
	
	redirect_to root_path
  end
  
  def savejustification
	j = Justification.new(:user_id => user_id, :date => params[:date], :motive => params[:motive])
	j.save
	redirect_to root_path
  end
  
  def print
	if !params[:print].present?
		return
	end
	first = Date.parse(params[:print])
	last = first + 1.month - 1.day
	checks = ActiveRecord::Base.connection.select_all "select DATE(check_timestamp) as check_date, TIME(check_timestamp) as check_time from checks where user_id = '#{user_id}' and DATE(check_timestamp) BETWEEN DATE('#{first}') AND DATE('#{last}') ORDER BY DATE(check_timestamp)"
	if checks.blank?
		return
	end
	count = 1
	sum = 0.0
	date1 = nil
	time1 = nil
	@html = ""
	checks.each do |check|
		if check["check_date"] != date1
			@html += "#{date1} #{floatToHours(sum/3600)}\n" unless date1.blank?
			sum = 0.0
			date1 = check["check_date"]
			time1 = check["check_time"]
		else
			if count%2 == 0
				sum += ("#{check["check_date"]} #{check["check_time"]}").to_time - ("#{date1} #{time1}").to_time
			else
				date1 = check["check_date"]
				time1 = check["check_time"]
			end
		end
		count += 1
	end
  end

end
