require 'mechanize'  #gem install mechanize

class Dosign
  def initialize(account, password)
    @agent = Mechanize.new
    @account = account
    @password = password
  end

  def login
    resp = @agent.post('http://www.zimuzu.tv/User/Login/ajaxLogin', {
      :account => @account,
      :password => @password
    })
  end

  def dosign
    # 先访问这个页面伪造 PHPSESSID
    resp = @agent.get 'http://www.zimuzu.tv/user/sign'

    # 限制15秒以上
    sleep 16

    # 签到
    resp = @agent.get 'http://www.zimuzu.tv/user/sign/dosign'

    time = Time.new.strftime("%Y-%m-%d %H:%M:%S")

    # 定时任务输出结果
    log_file = File.open 'log.txt', 'a'

    if JSON.parse(resp.body)['status'] == 1
      log_file.puts time.to_s + ' 签到成功!'
      puts '签到成功'
    else
      log_file.puts time.to_s + ' 签到失败'
      puts '签到失败'
    end

    log_file.close
  end

  def main
    # 先登录获取cookie, 同一个@agent 可以共享 cookie
    login
    # 再签到
    dosign
  end
end

dosign = Dosign.new('username', '*******')
dosign.main