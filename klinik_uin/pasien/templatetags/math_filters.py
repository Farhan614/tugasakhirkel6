from django import template

register = template.Library()

@register.filter
def multiply(value, arg):
    try:
        return int(value) * float(arg)
    except (ValueError, TypeError):
        return 0