
if ENV["RAILS_ENV"] == "development"
  worker_processes 3
else
  worker_processes 3
end

timeout 1200