# f_helper functions for water years

# function for water year day
add_wyd <- function(date, start_mon = 10L){

  start_yr <- year(date) - (month(date) < start_mon)
  start_date <- make_date(start_yr, start_mon, 1L)
  wyd <- as.integer(date - start_date + 1L)
  # deal with leap year
  offsetyr <- ifelse(lubridate::leap_year(date), 1, 0) # Leap Year offset
  adj_wyd <- ifelse(offsetyr==1 & month(date) >= start_mon, wyd - 1, wyd)
  return(adj_wyd)
}

# function for water year week
add_wyweek <- function(wyday){
  wyw <- wyday %/% 7 + 1
  return(wyw)
}

# add_wyweek <- function(date){
#   wyw <- ifelse(month(date) > 9,
#                 week(date) - week(make_date(year(date), 9, 30)),
#                 week(date) + (week(make_date(year(date), 12, 31))- week(make_date(year(date), 10, 1))))
#   wyw <- ifelse(wyw==0, 1, wyw)
#   return(wyw)
# }
