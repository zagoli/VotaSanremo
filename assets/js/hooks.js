import simplyCountdown from "simplycountdown.js"

const Countdown = {
    mounted() {
        const date = new Date(this.el.dataset.votesStartDatetime);
        this.setTimer(date);
    },
    updated() {
        const date = new Date(this.el.dataset.votesStartDatetime);
        this.setTimer(date);
    },
    setTimer(date) {
        simplyCountdown("#countdown", {
            year: date.getFullYear(),
            month: date.getMonth() + 1,
            day: date.getDate(),
            hours: date.getHours(),
            minutes: date.getMinutes(),
            seconds: date.getSeconds(),
            inline: true,
            removeZeroUnits: true,
            words: {
                days: { lambda: () => "giorni" },
                hours: { lambda: () => "ore" },
                minutes: { lambda: () => "minuti" },
                seconds: { lambda: () => "secondi" },
            }
        });
    }
}

export const Hooks = {
    Countdown
}